#!/usr/bin/python3
#
# Script to generate corrupted Windows NT Registry (REGF) test files

import os
import shutil


if __name__ == '__main__':
  corrupted_specimens = os.path.join('specimens', 'corrupted')
  if not os.path.exists(corrupted_specimens):
    os.mkdir(corrupted_specimens)

  regf_specimen = os.path.join('specimens', '10.0', '100_sub_keys.hiv')

  # Scenario: corrupt sub key list.
  corrupted_regf_specimen = os.path.join(
      corrupted_specimens, 'corrupt_sub_key_list.hiv')
  if os.path.isfile(regf_specimen):
    shutil.copyfile(regf_specimen, corrupted_regf_specimen)

    with open(corrupted_regf_specimen, 'r+b') as file_object:
      file_object.seek(0x4bc8, os.SEEK_SET)
      file_object.write(b'\x80\x44\x00\00')
