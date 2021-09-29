--
-- Unicode characters not to encode with escape sequences in strings.
-- Updated: 2021-05-17
--

-- U+1234  = include
-- !U+1234 = exclude
-- U+1x3x  = 'x' means range between 0 and F
local codepointsStr = [[

Source: https://en.wikipedia.org/wiki/List_of_Unicode_characters
----------------------------------------------------------------

Basic Latin
U+0020 (space)
U+0021 !
U+0022 "
U+0023 #
U+0024 $
U+0025 %
U+0026 &
U+0027 '
U+0028 (
U+0029 )
U+002A *
U+002B +
U+002C ,
U+002D -
U+002E .
U+002F /
U+0030 0
U+0031 1
U+0032 2
U+0033 3
U+0034 4
U+0035 5
U+0036 6
U+0037 7
U+0038 8
U+0039 9
U+003A :
U+003B ;
U+003C <
U+003D =
U+003E >
U+003F ?
U+0040 @
U+0041 A
U+0042 B
U+0043 C
U+0044 D
U+0045 E
U+0046 F
U+0047 G
U+0048 H
U+0049 I
U+004A J
U+004B K
U+004C L
U+004D M
U+004E N
U+004F O
U+0050 P
U+0051 Q
U+0052 R
U+0053 S
U+0054 T
U+0055 U
U+0056 V
U+0057 W
U+0058 X
U+0059 Y
U+005A Z
U+005B [
U+005C \
U+005D ]
U+005E ^
U+005F _
U+0060 `
U+0061 a
U+0062 b
U+0063 c
U+0064 d
U+0065 e
U+0066 f
U+0067 g
U+0068 h
U+0069 i
U+006A j
U+006B k
U+006C l
U+006D m
U+006E n
U+006F o
U+0070 p
U+0071 q
U+0072 r
U+0073 s
U+0074 t
U+0075 u
U+0076 v
U+0077 w
U+0078 x
U+0079 y
U+007A z
U+007B {
U+007C |
U+007D }
U+007E ~

Latin-1 Supplement
U+00A1 ¡
U+00A2 ¢
U+00A3 £
U+00A4 ¤
U+00A5 ¥
U+00A6 ¦
U+00A7 §
U+00A8 ¨
U+00A9 ©
U+00AA ª
U+00AB «
U+00AC ¬
U+00AD
U+00AE ®
U+00AF ¯
U+00B0 °
U+00B1 ±
U+00B2 ²
U+00B3 ³
U+00B4 ´
U+00B5 µ
U+00B6 ¶
U+00B7 ·
U+00B8 ¸
U+00B9 ¹
U+00BA º
U+00BB »
U+00BC ¼
U+00BD ½
U+00BE ¾
U+00BF ¿
U+00C0 À
U+00C1 Á
U+00C2 Â
U+00C3 Ã
U+00C4 Ä
U+00C5 Å
U+00C6 Æ
U+00C7 Ç
U+00C8 È
U+00C9 É
U+00CA Ê
U+00CB Ë
U+00CC Ì
U+00CD Í
U+00CE Î
U+00CF Ï
U+00D0 Ð
U+00D1 Ñ
U+00D2 Ò
U+00D3 Ó
U+00D4 Ô
U+00D5 Õ
U+00D6 Ö
U+00D7 ×
U+00D8 Ø
U+00D9 Ù
U+00DA Ú
U+00DB Û
U+00DC Ü
U+00DD Ý
U+00DE Þ
U+00DF ß
U+00E0 à
U+00E1 á
U+00E2 â
U+00E3 ã
U+00E4 ä
U+00E5 å
U+00E6 æ
U+00E7 ç
U+00E8 è
U+00E9 é
U+00EA ê
U+00EB ë
U+00EC ì
U+00ED í
U+00EE î
U+00EF ï
U+00F0 ð
U+00F1 ñ
U+00F2 ò
U+00F3 ó
U+00F4 ô
U+00F5 õ
U+00F6 ö
U+00F7 ÷
U+00F8 ø
U+00F9 ù
U+00FA ú
U+00FB û
U+00FC ü
U+00FD ý
U+00FE þ
U+00FF ÿ

Latin Extended-A
U+0100 Ā
U+0101 ā
U+0102 Ă
U+0103 ă
U+0104 Ą
U+0105 ą
U+0106 Ć
U+0107 ć
U+0108 Ĉ
U+0109 ĉ
U+010A Ċ
U+010B ċ
U+010C Č
U+010D č
U+010E Ď
U+010F ď
U+0110 Đ
U+0111 đ
U+0112 Ē
U+0113 ē
U+0114 Ĕ
U+0115 ĕ
U+0116 Ė
U+0117 ė
U+0118 Ę
U+0119 ę
U+011A Ě
U+011B ě
U+011C Ĝ
U+011D ĝ
U+011E Ğ
U+011F ğ
U+0120 Ġ
U+0121 ġ
U+0122 Ģ
U+0123 ģ
U+0124 Ĥ
U+0125 ĥ
U+0126 Ħ
U+0127 ħ
U+0128 Ĩ
U+0129 ĩ
U+012A Ī
U+012B ī
U+012C Ĭ
U+012D ĭ
U+012E Į
U+012F į
U+0130 İ
U+0131 ı
U+0132 Ĳ
U+0133 ĳ
U+0134 Ĵ
U+0135 ĵ
U+0136 Ķ
U+0137 ķ
U+0138 ĸ
U+0139 Ĺ
U+013A ĺ
U+013B Ļ
U+013C ļ
U+013D Ľ
U+013E ľ
U+013F Ŀ
U+0140 ŀ
U+0141 Ł
U+0142 ł
U+0143 Ń
U+0144 ń
U+0145 Ņ
U+0146 ņ
U+0147 Ň
U+0148 ň
U+0149 ŉ
U+014A Ŋ
U+014B ŋ
U+014C Ō
U+014D ō
U+014E Ŏ
U+014F ŏ
U+0150 Ő
U+0151 ő
U+0152 Œ
U+0153 œ
U+0154 Ŕ
U+0155 ŕ
U+0156 Ŗ
U+0157 ŗ
U+0158 Ř
U+0159 ř
U+015A Ś
U+015B ś
U+015C Ŝ
U+015D ŝ
U+015E Ş
U+015F ş
U+0160 Š
U+0161 š
U+0162 Ţ
U+0163 ţ
U+0164 Ť
U+0165 ť
U+0166 Ŧ
U+0167 ŧ
U+0168 Ũ
U+0169 ũ
U+016A Ū
U+016B ū
U+016C Ŭ
U+016D ŭ
U+016E Ů
U+016F ů
U+0170 Ű
U+0171 ű
U+0172 Ų
U+0173 ų
U+0174 Ŵ
U+0175 ŵ
U+0176 Ŷ
U+0177 ŷ
U+0178 Ÿ
U+0179 Ź
U+017A ź
U+017B Ż
U+017C ż
U+017D Ž
U+017E ž
U+017F ſ

Latin Extended-B
U+0180 ƀ
U+0181 Ɓ
U+0182 Ƃ
U+0183 ƃ
U+0184 Ƅ
U+0185 ƅ
U+0186 Ɔ
U+0187 Ƈ
U+0188 ƈ
U+0189 Ɖ
U+018A Ɗ
U+018B Ƌ
U+018C ƌ
U+018D ƍ
U+018E Ǝ
U+018F Ə
U+0190 Ɛ
U+0191 Ƒ
U+0192 ƒ
U+0193 Ɠ
U+0194 Ɣ
U+0195 ƕ
U+0196 Ɩ
U+0197 Ɨ
U+0198 Ƙ
U+0199 ƙ
U+019A ƚ
U+019B ƛ
U+019C Ɯ
U+019D Ɲ
U+019E ƞ
U+019F Ɵ
U+01A0 Ơ
U+01A1 ơ
U+01A2 Ƣ
U+01A3 ƣ
U+01A4 Ƥ
U+01A5 ƥ
U+01A6 Ʀ
U+01A7 Ƨ
U+01A8 ƨ
U+01A9 Ʃ
U+01AA ƪ
U+01AB ƫ
U+01AC Ƭ
U+01AD ƭ
U+01AE Ʈ
U+01AF Ư
U+01B0 ư
U+01B1 Ʊ
U+01B2 Ʋ
U+01B3 Ƴ
U+01B4 ƴ
U+01B5 Ƶ
U+01B6 ƶ
U+01B7 Ʒ
U+01B8 Ƹ
U+01B9 ƹ
U+01BA ƺ
U+01BB ƻ
U+01BC Ƽ
U+01BD ƽ
U+01BE ƾ
U+01BF ƿ
U+01C0 ǀ
U+01C1 ǁ
U+01C2 ǂ
U+01C3 ǃ
U+01C4 Ǆ
U+01C5 ǅ
U+01C6 ǆ
U+01C7 Ǉ
U+01C8 ǈ
U+01C9 ǉ
U+01CA Ǌ
U+01CB ǋ
U+01CC ǌ
U+01CD Ǎ
U+01CE ǎ
U+01CF Ǐ
U+01D0 ǐ
U+01D1 Ǒ
U+01D2 ǒ
U+01D3 Ǔ
U+01D4 ǔ
U+01D5 Ǖ
U+01D6 ǖ
U+01D7 Ǘ
U+01D8 ǘ
U+01D9 Ǚ
U+01DA ǚ
U+01DB Ǜ
U+01DC ǜ
U+01DD ǝ
U+01DE Ǟ
U+01DF ǟ
U+01E0 Ǡ
U+01E1 ǡ
U+01E2 Ǣ
U+01E3 ǣ
U+01E4 Ǥ
U+01E5 ǥ
U+01E6 Ǧ
U+01E7 ǧ
U+01E8 Ǩ
U+01E9 ǩ
U+01EA Ǫ
U+01EB ǫ
U+01EC Ǭ
U+01ED ǭ
U+01EE Ǯ
U+01EF ǯ
U+01F0 ǰ
U+01F1 Ǳ
U+01F2 ǲ
U+01F3 ǳ
U+01F4 Ǵ
U+01F5 ǵ
U+01F6 Ƕ
U+01F7 Ƿ
U+01F8 Ǹ
U+01F9 ǹ
U+01FA Ǻ
U+01FB ǻ
U+01FC Ǽ
U+01FD ǽ
U+01FE Ǿ
U+01FF ǿ
U+0200 Ȁ
U+0201 ȁ
U+0202 Ȃ
U+0203 ȃ
U+0204 Ȅ
U+0205 ȅ
U+0206 Ȇ
U+0207 ȇ
U+0208 Ȉ
U+0209 ȉ
U+020A Ȋ
U+020B ȋ
U+020C Ȍ
U+020D ȍ
U+020E Ȏ
U+020F ȏ
U+0210 Ȑ
U+0211 ȑ
U+0212 Ȓ
U+0213 ȓ
U+0214 Ȕ
U+0215 ȕ
U+0216 Ȗ
U+0217 ȗ
U+0218 Ș
U+0219 ș
U+021A Ț
U+021B ț
U+021C Ȝ
U+021D ȝ
U+021E Ȟ
U+021F ȟ
U+0220 Ƞ
U+0221 ȡ
U+0222 Ȣ
U+0223 ȣ
U+0224 Ȥ
U+0225 ȥ
U+0226 Ȧ
U+0227 ȧ
U+0228 Ȩ
U+0229 ȩ
U+022A Ȫ
U+022B ȫ
U+022C Ȭ
U+022D ȭ
U+022E Ȯ
U+022F ȯ
U+0230 Ȱ
U+0231 ȱ
U+0232 Ȳ
U+0233 ȳ
U+0234 ȴ
U+0235 ȵ
U+0236 ȶ
U+0237 ȷ
U+0238 ȸ
U+0239 ȹ
U+023A Ⱥ
U+023B Ȼ
U+023C ȼ
U+023D Ƚ
U+023E Ⱦ
U+023F ȿ
U+0240 ɀ
U+0241 Ɂ
U+0242 ɂ
U+0243 Ƀ
U+0244 Ʉ
U+0245 Ʌ
U+0246 Ɇ
U+0247 ɇ
U+0248 Ɉ
U+0249 ɉ
U+024A Ɋ
U+024B ɋ
U+024C Ɍ
U+024D ɍ
U+024E Ɏ
U+024F ɏ

Latin Extended Additional
U+1E02 Ḃ
U+1E03 ḃ
U+1E0A Ḋ
U+1E0B ḋ
U+1E1E Ḟ
U+1E1F ḟ
U+1E40 Ṁ
U+1E41 ṁ
U+1E56 Ṗ
U+1E57 ṗ
U+1E60 Ṡ
U+1E61 ṡ
U+1E6A Ṫ
U+1E6B ṫ
U+1E80 Ẁ
U+1E81 ẁ
U+1E82 Ẃ
U+1E83 ẃ
U+1E84 Ẅ
U+1E85 ẅ
U+1E9B ẛ
U+1EF2 Ỳ
U+1EF3 ỳ

Greek and Coptic
U+0370 Ͱ
U+0371 ͱ
U+0372 Ͳ
U+0373 ͳ
U+0374 ʹ
U+0375 ͵
U+0376 Ͷ
U+0377 ͷ
U+037A ͺ
U+037B ͻ
U+037C ͼ
U+037D ͽ
U+037E ;
U+037F Ϳ
U+0384 ΄
U+0385 ΅
U+0386 Ά
U+0387 ·
U+0388 Έ
U+0389 Ή
U+038A Ί
U+038C Ό
U+038E Ύ
U+038F Ώ
U+0390 ΐ
U+0391 Α
U+0392 Β
U+0393 Γ
U+0394 Δ
U+0395 Ε
U+0396 Ζ
U+0397 Η
U+0398 Θ
U+0399 Ι
U+039A Κ
U+039B Λ
U+039C Μ
U+039D Ν
U+039E Ξ
U+039F Ο
U+03A0 Π
U+03A1 Ρ
U+03A3 Σ
U+03A4 Τ
U+03A5 Υ
U+03A6 Φ
U+03A7 Χ
U+03A8 Ψ
U+03A9 Ω
U+03AA Ϊ
U+03AB Ϋ
U+03AC ά
U+03AD έ
U+03AE ή
U+03AF ί
U+03B0 ΰ
U+03B1 α
U+03B2 β
U+03B3 γ
U+03B4 δ
U+03B5 ε
U+03B6 ζ
U+03B7 η
U+03B8 θ
U+03B9 ι
U+03BA κ
U+03BB λ
U+03BC μ
U+03BD ν
U+03BE ξ
U+03BF ο
U+03C0 π
U+03C1 ρ
U+03C2 ς
U+03C3 σ
U+03C4 τ
U+03C5 υ
U+03C6 φ
U+03C7 χ
U+03C8 ψ
U+03C9 ω
U+03CA ϊ
U+03CB ϋ
U+03CC ό
U+03CD ύ
U+03CE ώ
U+03CF Ϗ
U+03D0 ϐ
U+03D1 ϑ
U+03D2 ϒ
U+03D3 ϓ
U+03D4 ϔ
U+03D5 ϕ
U+03D6 ϖ
U+03D7 ϗ
U+03D8 Ϙ
U+03D9 ϙ
U+03DA Ϛ
U+03DB ϛ
U+03DC Ϝ
U+03DD ϝ
U+03DE Ϟ
U+03DF ϟ
U+03E0 Ϡ
U+03E1 ϡ
U+03E2 Ϣ
U+03E3 ϣ
U+03E4 Ϥ
U+03E5 ϥ
U+03E6 Ϧ
U+03E7 ϧ
U+03E8 Ϩ
U+03E9 ϩ
U+03EA Ϫ
U+03EB ϫ
U+03EC Ϭ
U+03ED ϭ
U+03EE Ϯ
U+03EF ϯ
U+03F0 ϰ
U+03F1 ϱ
U+03F2 ϲ
U+03F3 ϳ
U+03F4 ϴ
U+03F5 ϵ
U+03F6 ϶
U+03F7 Ϸ
U+03F8 ϸ
U+03F9 Ϲ
U+03FA Ϻ
U+03FB ϻ
U+03FC ϼ
U+03FD Ͻ
U+03FE Ͼ
U+03FF Ͽ

Cyrillic
U+0400 Ѐ
U+0401 Ё
U+0402 Ђ
U+0403 Ѓ
U+0404 Є
U+0405 Ѕ
U+0406 І
U+0407 Ї
U+0408 Ј
U+0409 Љ
U+040A Њ
U+040B Ћ
U+040C Ќ
U+040D Ѝ
U+040E Ў
U+040F Џ
U+0410 А
U+0411 Б
U+0412 В
U+0413 Г
U+0414 Д
U+0415 Е
U+0416 Ж
U+0417 З
U+0418 И
U+0419 Й
U+041A К
U+041B Л
U+041C М
U+041D Н
U+041E О
U+041F П
U+0420 Р
U+0421 С
U+0422 Т
U+0423 У
U+0424 Ф
U+0425 Х
U+0426 Ц
U+0427 Ч
U+0428 Ш
U+0429 Щ
U+042A Ъ
U+042B Ы
U+042C Ь
U+042D Э
U+042E Ю
U+042F Я
U+0430 а
U+0431 б
U+0432 в
U+0433 г
U+0434 д
U+0435 е
U+0436 ж
U+0437 з
U+0438 и
U+0439 й
U+043A к
U+043B л
U+043C м
U+043D н
U+043E о
U+043F п
U+0440 р
U+0441 с
U+0442 т
U+0443 у
U+0444 ф
U+0445 х
U+0446 ц
U+0447 ч
U+0448 ш
U+0449 щ
U+044A ъ
U+044B ы
U+044C ь
U+044D э
U+044E ю
U+044F я
U+0450 ѐ
U+0451 ё
U+0452 ђ
U+0453 ѓ
U+0454 є
U+0455 ѕ
U+0456 і
U+0457 ї
U+0458 ј
U+0459 љ
U+045A њ
U+045B ћ
U+045C ќ
U+045D ѝ
U+045E ў
U+045F џ
U+0460 Ѡ
U+0461 ѡ
U+0462 Ѣ
U+0463 ѣ
U+0464 Ѥ
U+0465 ѥ
U+0466 Ѧ
U+0467 ѧ
U+0468 Ѩ
U+0469 ѩ
U+046A Ѫ
U+046B ѫ
U+046C Ѭ
U+046D ѭ
U+046E Ѯ
U+046F ѯ
U+0470 Ѱ
U+0471 ѱ
U+0472 Ѳ
U+0473 ѳ
U+0474 Ѵ
U+0475 ѵ
U+0476 Ѷ
U+0477 ѷ
U+0478 Ѹ
U+0479 ѹ
U+047A Ѻ
U+047B ѻ
U+047C Ѽ
U+047D ѽ
U+047E Ѿ
U+047F ѿ
U+0480 Ҁ
U+0481 ҁ
U+0482 ҂
U+048A Ҋ
U+048B ҋ
U+048C Ҍ
U+048D ҍ
U+048E Ҏ
U+048F ҏ
U+0490 Ґ
U+0491 ґ
U+0492 Ғ
U+0493 ғ
U+0494 Ҕ
U+0495 ҕ
U+0496 Җ
U+0497 җ
U+0498 Ҙ
U+0499 ҙ
U+049A Қ
U+049B қ
U+049C Ҝ
U+049D ҝ
U+049E Ҟ
U+049F ҟ
U+04A0 Ҡ
U+04A1 ҡ
U+04A2 Ң
U+04A3 ң
U+04A4 Ҥ
U+04A5 ҥ
U+04A6 Ҧ
U+04A7 ҧ
U+04A8 Ҩ
U+04A9 ҩ
U+04AA Ҫ
U+04AB ҫ
U+04AC Ҭ
U+04AD ҭ
U+04AE Ү
U+04AF ү
U+04B0 Ұ
U+04B1 ұ
U+04B2 Ҳ
U+04B3 ҳ
U+04B4 Ҵ
U+04B5 ҵ
U+04B6 Ҷ
U+04B7 ҷ
U+04B8 Ҹ
U+04B9 ҹ
U+04BA Һ
U+04BB һ
U+04BC Ҽ
U+04BD ҽ
U+04BE Ҿ
U+04BF ҿ
U+04C0 Ӏ
U+04C1 Ӂ
U+04C2 ӂ
U+04C3 Ӄ
U+04C4 ӄ
U+04C5 Ӆ
U+04C6 ӆ
U+04C7 Ӈ
U+04C8 ӈ
U+04C9 Ӊ
U+04CA ӊ
U+04CB Ӌ
U+04CC ӌ
U+04CD Ӎ
U+04CE ӎ
U+04CF ӏ
U+04D0 Ӑ
U+04D1 ӑ
U+04D2 Ӓ
U+04D3 ӓ
U+04D4 Ӕ
U+04D5 ӕ
U+04D6 Ӗ
U+04D7 ӗ
U+04D8 Ә
U+04D9 ә
U+04DA Ӛ
U+04DB ӛ
U+04DC Ӝ
U+04DD ӝ
U+04DE Ӟ
U+04DF ӟ
U+04E0 Ӡ
U+04E1 ӡ
U+04E2 Ӣ
U+04E3 ӣ
U+04E4 Ӥ
U+04E5 ӥ
U+04E6 Ӧ
U+04E7 ӧ
U+04E8 Ө
U+04E9 ө
U+04EA Ӫ
U+04EB ӫ
U+04EC Ӭ
U+04ED ӭ
U+04EE Ӯ
U+04EF ӯ
U+04F0 Ӱ
U+04F1 ӱ
U+04F2 Ӳ
U+04F3 ӳ
U+04F4 Ӵ
U+04F5 ӵ
U+04F6 Ӷ
U+04F7 ӷ
U+04F8 Ӹ
U+04F9 ӹ
U+04FA Ӻ
U+04FB ӻ
U+04FC Ӽ
U+04FD ӽ
U+04FE Ӿ
U+04FF ӿ

Unicode symbols
U+2013 –
U+2014 —
U+2015 ―
U+2017 ‗
U+2018 ‘
U+2019 ’
U+201A ‚
U+201B ‛
U+201C “
U+201D ”
U+201E „
U+2020 †
U+2021 ‡
U+2022 •
U+2026 …
U+2030 ‰
U+2032 ′
U+2033 ″
U+2039 ‹
U+203A ›
U+203C ‼
U+203E ‾
U+2044 ⁄
U+204A ⁊

Source: https://en.wikipedia.org/wiki/Unicode_block
----------------------------------------------------------------

General Punctuation
U+201x !U+2011
U+2020 U+2021 U+2022 U+2023 U+2024 U+2025 U+2026 U+2027
U+203x
U+204x
U+205x !U+205F

Superscripts and Subscripts
U+207x !U+2072 !U+2073
U+208x !U+208F
U+209x !U+209D !U+209E !U+209F

Currency Symbols
U+20Ax
U+20Bx

Letterlike Symbols
U+210x
U+211x
U+212x
U+213x
U+214x

Number Forms
U+215x
U+216x
U+217x
U+218x !U+218C !U+218D !U+218E !U+218F

Arrows
U+219x
U+21Ax
U+21Bx
U+21Cx
U+21Dx
U+21Ex
U+21Fx

Mathematical Operators
U+220x
U+221x
U+222x
U+223x
U+224x
U+225x
U+226x
U+227x
U+228x
U+229x
U+22Ax
U+22Bx
U+22Cx
U+22Dx
U+22Ex
U+22Fx

Miscellaneous Technical
U+230x
U+231x
U+232x
U+233x
U+234x
U+235x
U+236x
U+237x
U+238x
U+239x
U+23Ax
U+23Bx
U+23Cx
U+23Dx
U+23Ex
U+23Fx

Control Pictures
U+240x
U+241x
U+2420 U+2421 U+2422 U+2423 U+2424 U+2425 U+2426

Enclosed Alphanumerics
U+246x
U+247x
U+248x
U+249x
U+24Ax
U+24Bx
U+24Cx
U+24Dx
U+24Ex
U+24Fx

Box Drawing
U+250x
U+251x
U+252x
U+253x
U+254x
U+255x
U+256x
U+257x

Block Elements
U+258x
U+259x

Geometric Shapes
U+25Ax
U+25Bx
U+25Cx
U+25Dx
U+25Ex
U+25Fx

Miscellaneous Symbols
U+260x
U+261x
U+262x
U+263x
U+264x
U+265x
U+266x
U+267x
U+268x
U+269x
U+26Ax
U+26Bx
U+26Cx
U+26Dx
U+26Ex
U+26Fx

Dingbats
U+270x
U+271x
U+272x
U+273x
U+274x
U+275x
U+276x
U+277x
U+278x
U+279x
U+27Ax
U+27Bx

Miscellaneous Mathematical Symbols-A
U+27Cx
U+27Dx
U+27Ex

Supplemental Arrows-A
U+27Fx

Supplemental Arrows-B
U+290x
U+291x
U+292x
U+293x
U+294x
U+295x
U+296x
U+297x

Miscellaneous Mathematical Symbols-B
U+298x
U+299x
U+29Ax
U+29Bx
U+29Cx
U+29Dx
U+29Ex
U+29Fx

Supplemental Mathematical Operators
U+2A0x
U+2A1x
U+2A2x
U+2A3x
U+2A4x
U+2A5x
U+2A6x
U+2A7x
U+2A8x
U+2A9x
U+2AAx
U+2ABx
U+2ACx
U+2ADx
U+2AEx
U+2AFx

Alphabetic Presentation Forms
U+FB00 U+FB01 U+FB02 U+FB03 U+FB04 U+FB05 U+FB06

Mathematical Alphanumeric Symbols
(some of these seem problematic)
]]

local lowest  = 1/0
local highest = 0
local cpSet   = {}

local function eachCodepoint(cpHexPattern)
	if not cpHexPattern:find"[Xx]" then
		local cpHex = cpHexPattern
		local done  = false

		return function()
			if not done then
				done = true
				return tonumber(cpHex, 16)
			end
		end
	end

	-- Every 'x' in the hex number pattern is a variable.
	local variables = {}

	for _ in cpHexPattern:gmatch"[Xx]" do
		table.insert(variables, 0)
	end

	variables[#variables] = -1

	return function()
		-- Increase the number represented by the variables.
		for i = #variables, 1, -1 do
			variables[i] = variables[i] + 1
			if variables[i] < 16 then  break  end
			variables[i] = 0
			if i == 1 then  return  end -- Done!
		end

		local i = 0

		local cpHex = cpHexPattern:gsub("[Xx]", function()
			i = i + 1
			return ("%X"):format(variables[i])
		end)

		return tonumber(cpHex, 16)
	end
end

for ignore, cpHexPattern in codepointsStr:gmatch"(!?)U%+0*([%xXx]+)" do
	ignore = (ignore == "!")

	for cp in eachCodepoint(cpHexPattern) do
		if ignore then
			print(("Ignoring U+%04X"):format(cp))
		elseif cpSet[cp] then
			print(("Duplicate U+%04X"):format(cp))
		end

		lowest    = math.min(lowest,  cp) -- (It's fine if lowest and highest becomes incorrect if ignore is ever true.)
		highest   = math.max(highest, cp)
		cpSet[cp] = not ignore
	end
end

local ranges     = {}
local rangeStart = lowest

for cp = lowest, highest do
	if cpSet[cp] then
		rangeStart = rangeStart or cp
	end
	if not cpSet[cp+1] and rangeStart then
		table.insert(ranges, {from=rangeStart, to=cp})
		rangeStart = nil
	end
end

print("{")
for i, range in ipairs(ranges) do
	print("\t{from="..range.from..", to="..range.to.."},")
end
print("}")
