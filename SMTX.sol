// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
pragma solidity ^0.8.0;

contract SMTXToken is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _initialSupply;
    mapping(address => bool) public blacklisted;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    function initialize() public initializer {
        __ERC20_init("SUMOTEX", "SMTX");
        __Ownable_init();
        __Pausable_init();
        _totalSupply = 1000000000 * 10**uint256(decimals());
        _mint(msg.sender, 200000000 * 10**uint256(decimals()));
    }

    /**
     * @dev total number of tokens in existence
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value)
        public
        override
        whenNotPaused
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= _balances[msg.sender]);
        require(blacklisted[msg.sender] != true);

        // SafeMath.sub will throw if there is not enough balance.
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return _balances[_owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override whenNotPaused returns (bool) {
        require(_to != address(0));
        require(_value <= _balances[_from]);
        require(_value <= _allowances[_from][msg.sender]);
        require(msg.data.length == 68);
        require(blacklisted[msg.sender] != true);
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(
            _value
        );
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address to, uint256 amount) public whenNotPaused onlyOwner {
        require(_initialSupply + amount <= _totalSupply);
        _mint(to, amount * 10**uint256(decimals()));
        _initialSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addblackListUser(address _blacklistUser)
        public
        whenNotPaused
        onlyOwner
    {
        blacklisted[_blacklistUser] = true;
    }

    function removeblackListUser(address _blacklistUser)
        public
        whenNotPaused
        onlyOwner
    {
        blacklisted[_blacklistUser] = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
