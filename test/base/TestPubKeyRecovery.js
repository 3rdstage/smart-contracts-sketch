const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const Account = require('eth-lib/lib/account');
const Bytes = require('eth-lib/lib/bytes');
const {keccak256, keccak256s} = require('eth-lib/lib/hash');
const elliptic = require('elliptic');
const secp256k1 = new (elliptic.ec)('secp256k1');

contract("Test public key recovery from the signature.", async accounts => {
  
  'use strict';
  
  //if(accounts.length == 10)   
  
  // References
  //   - https://github.com/ChainSafe/web3.js/blob/v1.3.4/packages/web3-eth-accounts/src/index.js#L335
  //   - https://github.com/MaiaVictor/eth-lib/blob/master/src/account.js
  it("", async() => {
    
    const prvkey = '0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e';
    const pubkey = '0x' + secp256k1.keyFromPrivate(
      new Buffer(prvkey.slice(2), "hex")).getPublic(false, "hex").slice(2);
    const addr = '0x' + keccak256(pubkey).slice(-40);
    
    console.log(`private key : ${prvkey}`);
    console.log(`public key  : ${pubkey}`);
    console.log(`address     : ${addr}`);
    
    assert.equal(addr.toUpperCase(), accounts[0].toUpperCase());
    
    const msg = 'We built this city.';
    const sig = await web3.eth.sign(msg, accounts[0]);
    console.log(`message     : ${msg}`);
    console.log(`signature   : ${sig}`);
    
    // recover address (not public key) using `web3.eth.accounts.recover()` function
    const addrRe = await web3.eth.accounts.recover(msg, sig);
    
    assert.equal(addrRe.toUpperCase(), addr.toUpperCase());
    console.log(`address recovered from signature : ${addrRe} - same with the above value`);
    
    const msgBytes = web3.utils.hexToBytes(web3.utils.utf8ToHex(msg));
    const preamble = '\x19Ethereum Signed Message:\n' + msgBytes.length;
    const msg191 = keccak256s(Buffer.concat([Buffer.from(preamble), Buffer.from(msgBytes)]));
    
    console.log(`EIP-191 applied message : ${msg191}`);
    
    // eth-lib/account/recover
    const vals = Account.decodeSignature(sig);
    const vrs = {v: Bytes.toNumber(vals[0]), r:vals[1].slice(2), s:vals[2].slice(2)};
    const pubkeyRe = '0x' + secp256k1.recoverPubKey(
        new Buffer(msg191.slice(2), "hex"), vrs, vrs.v < 2 ? vrs.v : 1 - (vrs.v % 2))
      .encode('hex', false).slice(2); 
    
    assert.equal(pubkeyRe.toUpperCase(), pubkey.toUpperCase());
    console.log(`public key recovered from signature : 
                ${pubkeyRe} - same with the above value`);
  })
  
})