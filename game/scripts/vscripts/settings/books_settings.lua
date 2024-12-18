-- values так же стоит менять в items_custom 
BOOKS_SHOP = {
	{
		name = "item_usual_book",
		rarity = UPGRADE_RARITY_COMMON,
		resources = {
			warsong = {
				gold = 1000,
			},
			dash = {
				gold = 2500,
			},
			portal_duo = {
				gold = 3000,
			},
			portal_trio = {
				gold = 3000,
			},
		}
	},
	{
		name = "item_rare_book",
		rarity = UPGRADE_RARITY_RARE,
		resources = {
			warsong = {
				gold = 3500,
				flags = 0,

			},
			dash = {
				gold = 4000,
				heads = 1,

			},
			portal_duo = {
				gold = 5500,
			},
			portal_trio = {
				gold = 5500,
			},
		}
	},
	{
		name = "item_epic_book",
		rarity = UPGRADE_RARITY_EPIC,
		resources = {
			warsong = {
				gold = 12000,
				flags = 1,
				purchaseType = "both",							
			},
			dash = {
				gold = 8000,
				heads = 1,	
				purchaseType = "both",			
			},
			portal_duo = {
				gold = 10000,
			},
			portal_trio = {
				gold = 11000,
			},
		}
	},
}

CustomNetTables:SetTableValue("books_shop", "books", BOOKS_SHOP)