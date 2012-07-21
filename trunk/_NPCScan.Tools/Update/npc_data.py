# -*- coding: utf_8 -*-
"""Builds a source file of NPC data for _NPCScan.Tools."""

import collections
import os.path
import re
import struct

import PyV8

import wowdata.dbc as dbc
import wowdata.lua
import wowdata.mpq
import wowdata.wowhead

__author__ = 'Saiket'
__email__ = 'saiket.wow@gmail.com'
__license__ = 'GPL'

_EXTRA_NPCS = set((
  50409,  # Mysterious Camel Figurine
  50410,  # Mysterious Camel Figurine
))
_FILTER_BY_ID = 37
_FILTER_EQUALS = 3
_BYTES_PER_COORD = 2
_COORD_MAX = 2 ** (8 * _BYTES_PER_COORD) - 1

class _JSBreak(Exception):
  """Sentinel exception thrown to stop JS execution once data is defined."""
  def __init__(self):  # Note: Older PyV8 builds always throw JSError, so identify by name instead
    super(_JSBreak, self).__init__(_JSBreak.__name__)


class _Globals(PyV8.JSClass):
  """JS global scope with simulated Wowhead APIs to intercept NPC data."""
  def Mapper(self, data):
    raise _JSBreak()


def _get_npc_data(npc_id, locale):
  """Returns this NPC's display ID and map data by AreaID and dungeon level."""
  page = wowdata.wowhead.get_page(locale, 'npc={:d}'.format(npc_id))
  display_id, area_data = None, None

  anchor = page.find('a', id='dsgndslgn464d')  # "View in 3D" button
  if anchor is not None and anchor.has_attr('onclick'):
    match = re.search(r'\bdisplayId: (\d+)\b', anchor['onclick'])
    if match is None:
      raise wowdata.wowhead.InvalidResultError(
        'DisplayID not found in onclick handler {!r}.'.format(anchor['onclick']))
    display_id = int(match.group(1))

  div = page.find('div', id='k6b43j6b')  # Map view
  if div is not None:
    try:
      script = div.find_next_sibling('script', type='text/javascript').get_text()
    except AttributeError:
      raise wowdata.wowhead.InvalidResultError('Map data script not found.')
    with PyV8.JSContext(_Globals()) as context:
      try:
        context.eval(script.encode('utf_8'))
      except _JSBreak:
        pass
      except PyV8.JSError as e:  # Note: Older PyV8 builds swallow custom exceptions
        if e.message != _JSBreak.__name__:
          raise
      try:
        mapper_data = context.locals.g_mapperData
      except AttributeError:
        raise wowdata.wowhead.InvalidResultError('Map data didn\'t define g_mapperData.')
      # Note: Workaround for PyV8.JSObject only allowing string keys
      get_value = context.eval('''
        (function ( Object, Key ) {
          return Object[ Key ];
        })
        ''')
      area_data = {}
      for area_id in mapper_data.keys():
        levels = get_value(mapper_data, area_id)
        area_data[area_id] = {}
        for level in levels.keys():
          vertices = []
          for vertex in get_value(levels, level)['coords']:
            vertices.append((float(vertex[0]) / 100, float(vertex[1]) / 100))
          area_data[area_id][level] = vertices
  return display_id, area_data


def _nested_default_dict():
  """Returns a `defaultdict` which automatically creates sub-dictionaries."""
  return collections.defaultdict(_nested_default_dict)


def write(output_filename, data_path, locale):
  """Compiles data about rare mobs from Wowhead to a Lua source file."""
  output_filename = os.path.normcase(output_filename)
  data_path = os.path.normcase(data_path)
  print 'Writing all rare NPC data from {:s} Wowhead to <{:s}>...'.format(locale, output_filename)
  npcs = wowdata.wowhead.get_npcs_all_levels(locale, cl='2:4')  # Rare and rare elite
  for npc_id in _EXTRA_NPCS.difference(npcs):
    npcs.update(wowdata.wowhead.get_search_results('npcs', locale,
      cr=_FILTER_BY_ID, crs=_FILTER_EQUALS, crv=npc_id))

  # Create a lookup for zone AreaTable IDs used by WowHead to WorldMapArea IDs
  with wowdata.mpq.open_locale_mpq(data_path, locale) as archive:
    with dbc.DBC(archive.open('DBFilesClient/WorldMapArea.dbc'),
      'id', None, 'area_id', flags=11) as worldmaps \
    :
      FLAG_PHASE = 0x2
      area_worldmap_ids = {}
      for worldmap in worldmaps:
        area_id = worldmap.int('area_id')
        if (area_id  # Not a continent
          and not worldmap.int('flags') & FLAG_PHASE  # Not a phased map
        ):
          area_worldmap_ids[area_id] = worldmap.int('id')

  # Query each NPC for details
  display_ids, worldmap_data = {}, _nested_default_dict()
  for npc_id, npc_data in sorted(npcs.iteritems()):
    print '\tNpc{:d} - {!r}'.format(npc_id, npc_data['name'].decode('utf_8'))
    try:
      display_id, area_data = _get_npc_data(npc_id, locale)
    except Exception as e:
      print '\t\tError reading NPC Data: {!r}'.format(e)
    else:
      if display_id is not None:
        display_ids[npc_id] = display_id
      if area_data is not None:
        # Merge into main world map data
        for area_id, levels in area_data.iteritems():
          if area_id in area_worldmap_ids:  # Has a world map
            for level, vertices in levels.iteritems():
              worldmap_data[area_worldmap_ids[area_id]][level][npc_id] = vertices

  with open(output_filename, 'w+b') as output:
    output.write('-- AUTOMATICALLY GENERATED BY <' + __file__.encode('utf_8') + '>!\n')
    output.write('select( 2, ... ).NPCData = {\n')

    output.write('\tNames = {\n')
    for npc_id, npc_data in sorted(npcs.iteritems()):
      output.write('\t\t[ ' + str(npc_id) + ' ] = '
        + wowdata.lua.escape_data(npc_data['name']) + ';\n')
    output.write('\t};\n')

    output.write('\tDisplayIDs = {\n')
    for npc_id, display_id in sorted(display_ids.iteritems()):
      output.write('\t\t[ ' + str(npc_id) + ' ] = ' + str(display_id) + ';\n')
    output.write('\t};\n')

    # Write point data per world map per floor.
    output.write('\tSightings = {\n')
    for worldmap_id, worldmap in sorted(worldmap_data.iteritems()):
      if worldmap:  # At least one level in world map
        output.write('\t\t[ ' + str(worldmap_id) + ' ] = {\n')
        for level, npc_data in sorted(worldmap.iteritems()):
          if npc_data:  # At least one NPC on this level
            output.write('\t\t\t[ ' + str(level) + ' ] = {\n')
            for npc_id, vertices in sorted(npc_data.iteritems()):
              if vertices:  # At least one known coordinate
                bytes = []
                for vertex in sorted(vertices):
                  for coord in vertex:
                    bytes.append(struct.pack('>H', round(coord * _COORD_MAX)))  # Big-endian unsigned short
                output.write('\t\t\t\t[ ' + str(npc_id) + ' ] = '
                  + wowdata.lua.escape_data(''.join(bytes)) + ';\n')
            output.write('\t\t\t};\n')
        output.write('\t\t};\n')
    output.write('\t};\n')
    output.write('};')


if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser(
    description='Compiles NPC data for _NPCScan.Tools.')
  parser.add_argument('--locale', '-l', type=unicode, required=True,
    help='Locale code to retrieve data for.')
  parser.add_argument('data_path', type=unicode,
    help='The path to World of Warcraft\'s Data folder.')
  parser.add_argument('output_filename', type=unicode,
    help='Output path for the resulting Lua source file.')
  write(**vars(parser.parse_args()))