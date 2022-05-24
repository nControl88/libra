//# init --validators Alice Bob Charlie Jim Lucy Thomas

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;
    fun main(sender: signer, _: signer) {
        TowerState::test_helper_set_weight_vm(&sender, @Alice, 10);
        assert!(NodeWeight::proof_of_weight(@Alice) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Bob, 10);
        assert!(NodeWeight::proof_of_weight(@Bob) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Charlie, 10);
        assert!(NodeWeight::proof_of_weight(@Charlie) == 10, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Jim, 31);
        assert!(NodeWeight::proof_of_weight(@Jim) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Lucy, 31);
        assert!(NodeWeight::proof_of_weight(@Lucy) == 31, 7357300101011088);
        TowerState::test_helper_set_weight_vm(&sender, @Thomas, 31);
        assert!(NodeWeight::proof_of_weight(@Thomas) == 31, 7357300101011088);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Lucy
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Jim
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @Lucy);
      assert!(Oracle::check_number_delegates(@Lucy) == 1, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Thomas
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @Alice);
      assert!(Oracle::check_number_delegates(@Alice) == 1, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Charlie
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::enable_delegation(&sender);
      Oracle::delegate_vote(&sender, @Lucy);
      assert!(Oracle::check_number_delegates(@Lucy) == 2, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Charlie
script {
  use DiemFramework::Oracle;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      Oracle::remove_delegate_vote(&sender);
      assert!(Oracle::check_number_delegates(@Lucy) == 1, 5);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"bello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 0);
      assert!(e == @Alice, 7357123401011000);
      let e = *Vector::borrow<address>(&vec, 1);
      assert!(e == @Thomas, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      let vec = Oracle::test_helper_query_oracle_votes();

      let e = *Vector::borrow<address>(&vec, 2);
      assert!(e == @Bob, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Thomas
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use Std::Hash;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      //already voted, must ensure vote not counted again
      let id = 2;
      let data = b"bello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = Vector::length<address>(&vec);
      assert!(e == 3, 7357123401011002);
    }
  }
}
// check: EXECUTED



//# run --admin-script --signers DiemRoot Lucy
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  use Std::Hash;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 2;
      let data = b"hello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 3);
      assert!(e == @Lucy, 7357123401011000);
      let e = *Vector::borrow<address>(&vec, 4);
      assert!(e == @Jim, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == false, 7357123401011001);
    }
  }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Jim
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 1;
      let data = b"hello";
      Oracle::handler(&sender, id, data);
      // ensure jim's vote is not counted twice
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = Vector::length<address>(&vec);
      assert!(e == 5, 7357123401011002);
    }
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Charlie
script {
  use DiemFramework::Oracle;
  use Std::Vector;
  use DiemFramework::Upgrade;
  use Std::Hash;
  fun main(_dr: signer, sender: signer){
    if (Oracle::delegation_enabled_upgrade()) {
      let id = 2;
      let data = b"hello";
      let hash = Hash::sha2_256(data);
      Oracle::handler(&sender, id, hash);
      let vec = Oracle::test_helper_query_oracle_votes();
      let e = *Vector::borrow<address>(&vec, 5);
      assert!(e == @Charlie, 7357123401011000);

      assert!(Upgrade::has_upgrade() == false, 7357123401011000); 
      assert!(Oracle::test_helper_check_upgrade() == true, 7357123401011001);
    }
  }
}
// check: EXECUTED

//# block --proposer Bob --time 1 --round 2

//# block --proposer Bob --time 2 --round 2

// //! new-transaction
// //! sender: diemroot
// script {
//   use DiemFramework::Upgrade;
//   use Std::Vector;
//   fun main(){
//     let (upgraded_version, payload, voters, height) = Upgrade::retrieve_latest_history();

//     let validators = Vector::empty<address>();
//     Vector::push_back(&mut validators, @Alice);
//     Vector::push_back(&mut validators, @Charlie);
//     assert!(upgraded_version == 0, 7357123401011000);
//     assert!(payload == b"hello", 7357123401011000);
//     assert!(VectorHelper::compare(&voters, &validators), 7357123401011000);
//     assert!(height == 1, 7357123401011000);
//   }
// }
// // check: EXECUTED