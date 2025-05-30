# jscpd:ignore-start
# pylint: disable=missing-module-docstring,duplicate-code
from typing import Dict, List, Optional

from ._vinted_wrapper import VintedWrapper
from .models import VintedItem


class VintedScraper(VintedWrapper):
    """
    Vinted client with data model support
    """

    def search(self, params: Optional[Dict] = None) -> List[VintedItem]:  # type: ignore
        """
        Search for items on Vinted.

        :param params: an optional Dictionary with all the query parameters to append
            to the request. Vinted supports a search without any parameters, but to
            perform a search, you should add the `search_text` parameter.
            Default value: None.
        :return: A list of VintedItem instances representing search results.
        """
        return [VintedItem(item) for item in super().search(params)["items"]]

    def item(self, item_id: str, params: Optional[Dict] = None) -> VintedItem:  # type: ignore
        """
        Retrieve details of a specific item on Vinted.

        :param item_id: The unique identifier of the item to retrieve.
        :param params: an optional Dictionary with all the query parameters to append
            to the request. Default value: None.
        :return: A VintedItem instance representing the item's details.
        """
        return VintedItem(super().item(item_id, params)["item"])


# jscpd:ignore-end
