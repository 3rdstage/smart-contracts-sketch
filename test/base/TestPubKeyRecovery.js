const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const Account = require('eth-lib/lib/account');
const Bytes = require('eth-lib/lib/bytes');
const {keccak256, keccak256s} = require('eth-lib/lib/hash');
const elliptic = require('elliptic');
const secp256k1 = new (elliptic.ec)('secp256k1');


const recoverPublicKey = (message, signature) => {

  const msgBytes = web3.utils.hexToBytes(web3.utils.utf8ToHex(message));
  const preamble = '\x19Ethereum Signed Message:\n' + msgBytes.length;
  const msg191 = keccak256s(Buffer.concat([Buffer.from(preamble), Buffer.from(msgBytes)]));

  const vals = Account.decodeSignature(signature);
  const vrs = {v: Bytes.toNumber(vals[0]), r:vals[1].slice(2), s:vals[2].slice(2)};
  const pubkey = '0x' + secp256k1.recoverPubKey(
      new Buffer(msg191.slice(2), "hex"), vrs, vrs.v < 2 ? vrs.v : 1 - (vrs.v % 2))
    .encode('hex', false).slice(2); 
      
  return pubkey
}


contract("Test public key recovery from the signature.", async accounts => {
  
  'use strict';
  
  //if(accounts.length == 10)   
  
  // References
  //   - https://github.com/ChainSafe/web3.js/blob/v1.3.4/packages/web3-eth-accounts/src/index.js#L335
  //   - https://github.com/MaiaVictor/eth-lib/blob/master/src/account.js
  it("Can recover public key from a message and its signature.", async() => {
    
    const sk = '0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e';
    const pk = '0x' + secp256k1.keyFromPrivate(
      new Buffer(sk.slice(2), "hex")).getPublic(false, "hex").slice(2);
    const addr = '0x' + keccak256(pk).slice(-40);
    
    assert.equal(addr.toUpperCase(), accounts[0].toUpperCase());
    console.log(`private key : ${sk}`);
    console.log(`public key  : ${pk}`);
    console.log(`address     : ${addr}`);
    
    const msg = 'We built this city.';
    const sig = await web3.eth.sign(msg, accounts[0]);
    console.log(`message     : ${msg}`);
    console.log(`ethereum signature   : ${sig}`);
    
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
    const pkRe = '0x' + secp256k1.recoverPubKey(
        new Buffer(msg191.slice(2), "hex"), vrs, vrs.v < 2 ? vrs.v : 1 - (vrs.v % 2))
      .encode('hex', false).slice(2); 
    
    assert.equal(pkRe.toUpperCase(), pk.toUpperCase());
    console.log(`public key recovered from signature : 
                ${pkRe} - same with the above value`);
  })
  
  
  it("Can recover public key from a message and its signature.", async() => {

    const sk = '0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e';
    const pk = '0x' + secp256k1.keyFromPrivate(
      new Buffer(sk.slice(2), "hex")).getPublic(false, "hex").slice(2);
    const addr = '0x' + keccak256(pk).slice(-40);
    
    assert.equal(addr.toUpperCase(), accounts[0].toUpperCase());
    console.log(`public key : ${pk}`)
    
    const test = async(msg) => {
      const sig = await web3.eth.sign(msg, accounts[0]);
      console.log(`message              : ${msg}`);
      console.log(`ethereum signature   : ${sig}`);
    
      const pkRe = recoverPublicKey(msg, sig)
      assert.equal(pk, pkRe);
      console.log(`recovered public key : ${pkRe}`);
    };
    
    await test('Life is Live');
    await test('내 마음 깊은 곳의 너');
    await test('12345^&*()');      
    
  })  

  
})