void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);
    if (!player) {
        // Assuming that all else works fine, this is the source of the memory leak.
        // If the player is not able to be found by name, then a Player is allocated on the heap and attempts to get loaded in on the next line.
        player = new Player(nullptr);
        // However, if the player still isn't able to be loaded in, then a memory leak happens because that allocated Player never gets deleted from the heap.
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            // I am under the impression that if the player is able to be loaded, it gets registered by the IOLoginData::loadPlayerByName.
            // Maybe it gets added to a static instance of this Game class/struct?
            delete(player);
            return;
        }
    }

    Item* item = Item::CreateItem(itemId);
    if (!item) {
        return;
    }

    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }
}