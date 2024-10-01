# Add metadata to your fonts

Playdate's `.fnt` format is not compatible with Love2D's `.fnt` format out of the box. Playdate uses [a custom format designed for use with Caps](https://sdk.play.date/1.9.3/Inside%20Playdate.html#_text), where as Love2D's uses the standard [BMFont](https://www.angelcode.com/products/bmfont/doc/file_format.html) format.

Playbit automatically handles _most_ of this conversion for you. However there are a few things that can't be automatically detected, so you'll need to add additional keys to your fonts.

- `playbit_width`: the width of your font's image (not the glyph).
- `playbit_height`: the height of your font's image (again, not the glyph).

For example, the SDK-provide font `Asheville-Mono-Light-24-px.fnt` starts like this:

```
space	14
!		14
"		14
#		14
$		14
%		14

and etc..
```

You can add the playbit keys anywhere in the file, like so:
```
playbit_width=512
playbit_height=256
space	14
!		14
"		14
#		14
$		14
%		14

and etc..
```