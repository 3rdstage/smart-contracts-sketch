

### ERC721Exportable Test-cases

####  Normal cases

* A token in normal state(owned by someone) can set exporting by the approved.
* A token in normal state(owned by someone) can set exporting by the owner.
* A token in exporting state can be set exported by the current owner.
* A token in exported state can be set imported to a new owner by the minter.
* A token previously imported can be set exporting by the approved.

#### Abnormal cases

* A token ID not minted yet can't be set exporting.
* A token in exporting state can't be set exporting.
* A token in exported state can't be approved to anyone.
* A token in exported state can't be set exporting.
* A token in normal state can't be set exporting by the message sender who is not the onwer nor the approved.

