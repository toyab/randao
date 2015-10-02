contract Randao {
  struct Participant {
    uint256   secret;
    bytes32   commitment;
  }
  struct Campaign {
    address[] paddresses;
    uint16    reveals;
    uint256   random;
    mapping (address => Participant) participants;
  }
  struct Consumer {
    address addr;
  }

  //mapping (uint => uint) public numbers;
  mapping (uint32 => Campaign) public campaigns;

  uint8  constant commit_deadline = 6;
  uint8  constant commit_balkline = 12;
  uint96 constant earnest_eth     = 10 ether;
  uint8  public   version         = 1;

  function Randao () {
  }

  function commit (uint32 bnum, bytes32 hs) external check_earnest {
    if(block.number >= bnum - commit_balkline && block.number < bnum - commit_deadline){
      Campaign c = campaigns[bnum];

      c.paddresses[c.paddresses.length++] = msg.sender;
      Participant p = c.participants[msg.sender];
      p.commitment = hs;
    } else {
      refund(msg.value);
    }
  }

  function reveal (uint32 bnum, uint256 s) external {
    if(block.number < bnum && block.number >= bnum - commit_deadline){
      Campaign c = campaigns[bnum];

      Participant p = c.participants[msg.sender];

      if(sha3(s) == p.commitment){
        if(p.secret != s){ c.reveals++; }
        p.secret = s;
      }
    } else {
      refund(msg.value);
    }
  }

  function reveals (uint32 bnum) returns (uint r){
    return campaigns[bnum].reveals;
  }

  function test() returns (bytes32 rtn) {
    return sha3(0x00, 0x00, 0x0002);
  }

  function random (uint32 bnum) constant returns (uint num) {
    var random = uint(0);
    Campaign c = campaigns[bnum];
    if(block.number >= bnum && c.reveals > 0 && c.reveals == c.paddresses.length){
      for (uint i = 0; i < c.paddresses.length; i++) {
        random ^= c.participants[c.paddresses[i]].secret;
      }
    }
    return random;
  }

  function refund (uint rvalue) private {
    // refund
    var fee = 100 * tx.gasprice;
    if(rvalue > fee){
      msg.sender.send(rvalue - fee);
    }
  }

  modifier check_earnest {
    var rvalue = uint256(0);
    if(msg.value < earnest_eth) {
      rvalue = msg.value;
    } else {
      rvalue = msg.value - earnest_eth;
      _
    }

    refund(rvalue);
  }
}