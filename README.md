# InventoryWTF
Updates your KoL inventory page with descriptions for items and effects

It will display information about the items in your inventory below their name.

## Shops and Stores
Thius includes an override for all SHOPS and STORES:
Anything that hits store.php or shop.php will be infused with WTF power!
It adds current available quantity via available_amount() to the item as well pretty modifier descriptions. This includes coloring for quality for food/booze.
If the item is a quest item, it will be highlighted yellow. If the item is a quest item AND you have more than 1, it will remove the MAKE or BUY button.  (This feature is mostly to avoid buying the wrong Hero keys.)

## Install
Run this command in the graphical CLI:
```
git checkout https://github.com/ckb11/InventoryWTF main
```
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).
