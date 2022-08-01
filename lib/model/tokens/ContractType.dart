enum ContractType {
  ERC20,
  ERC721,
  ERC1155,
  other;

  static ContractType fromString(String value) {
    switch(value){
      case 'ERC20':
        return ContractType.ERC20;
      case 'ERC721':
        return ContractType.ERC721;
      case 'ERC1155':
        return ContractType.ERC1155;
    }
    return ContractType.other;
  }
}

