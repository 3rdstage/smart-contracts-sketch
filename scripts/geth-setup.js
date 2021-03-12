
// Use lower version ECMAScript : go-ethereum now uses the GoJa JS VM which is compatible with ECMAScript 5.1.
// https://geth.ethereum.org/docs/rpc/ns-personal

var passphrase = 'none';
var keys = [
  "052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e",
  "6006fc64218112913e638a2aec5bd25199178cfaf9335a83b75c0e264e7d9cee",
  "724443258d598ee09e79bdbdc4af0792a69bd80082f68180157208aa6c5437de",
  "00f84e1eaf2918511f4690fb396c89928bebfbe5d96cd821069ecf16e921a4ee",
  "78394a06447e6688317ee920cefd3b992dee3d9ee9cb2462f22ab730723fab4a",
  "4f7b71565f80821fbad1e4a3c7b8c7a28297d40d5179e4aad5c071c0370a956d",
  "3410f72766f9be720638f02a0047b6cb2da3265f393d032caccdb0bd13854a58",
  "964a24a416c75097cfbc3d96ba06dadd8f6c8c7503fa5e95dd738241f4f01c3d",
  "a5b0a313105744bc0e45373034bed686b0c95fcb24f02ec70fb126d516561cd0",
  "b38ca892d2778a5edfb03141922becca5074497825335bbbcf2780fa114f0cf4"
]

for (i = 0; i < keys.length; i++){ 
  personal.importRawKey(keys[i], passphrase);
}

console.log('Successfully imported ' + keys.length + ' keys into the keystore')
