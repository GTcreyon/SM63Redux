0:
initial impl of JSON level format. Feature complete for the time, able to
save/load items with properties, polygons, level format version, and the
last position of the editor camera.

0.0.1:
Switch to Semantic Versioning. Major breaking changes can now be tracked
separate from minor, non-breaking changes and bugfix patches. Before
1.0.0, anything goes, though; would suggest bumping minor for features
and patch on refactoring existing features.

Reformat property serialization.
> Before: [X pos, Y pos, properties { ... }]
> After: properties { ... }	


## Roadmap
1.0.0:
Patch gets merged, is now available for the rest of the dev team to use.
Format becomes stable to whatever degree is possible.