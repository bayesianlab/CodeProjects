file(REMOVE_RECURSE
  "mvt.pdb"
  "mvt"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/mvt.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
