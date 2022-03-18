

### ERC721Exportable Test-cases

#### Normal basic cases

* A token in normal state(owned by someone) can set exporting by the approved.
* A token in normal state(owned by someone) can set exporting by the owner.
* A token in exporting state can be set exported by the current owner.
* A token in exported state can be set imported to a new owner by the minter.
* A token previously imported can be set exporting by the approved.

#### Normal extended cases

* A token imported can be transferred by the owner.
* A token imported can be transferred by the approved.
* Setting a token exporting doesn't change total supply at all.
* Setting a token exported decreases total supply by 1.
* Setting a token imported increases total supply by 1.

#### Abnormal cases

* A token ID not minted yet can't be set exporting.
* A token can be set exporting escrowed by the current owner.
* A token in exporting state can't be set exporting.
* A token in exported state can't be approved to anyone.
* A token in exported state can't be set exporting.
* A token in normal state can't be set exporting by the message sender who is not the onwer nor the approved.

#### Unusual cases

* A token in exporting state can be transferred by the escrowee.
