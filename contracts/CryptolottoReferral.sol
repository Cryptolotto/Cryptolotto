pragma solidity 0.4.24;

contract iOwnable {
    function allowed(address) public view returns (bool) {}
}

/**
* @title Cryptolotto Referral System
* 
* @dev Cryptolotto takes 10% commission after each draw. Cryptolotto redistributes its earnings on:
* @dev - salaries of Cryptolotto workers;
* @dev - advertisement campaigns for constant growth of players;
* @dev - security and maintenance of Cryptolotto servers;
* @dev - work on future updates;
* @dev - taxes in the state of residence of Cryptolotto;
* @dev - Cryptolotto Referral System.
*
* @dev Cryptolotto Referral System (CRS) allows splitting the commission after each draw 
* @dev between Cryptolotto, Influencers, and Sales (optional) by establishing the two-level 
* @dev partnership program built on blockchain-based algorithms. The source code of the CRS 
* @dev is stored on the Github and can be checked by any party at any time.
*
* @dev Cryptolotto Referral System is represented by the two levels:
* @dev - the influencer level;
* @dev - the sales level.
*
* @dev The influencer is a media outlet, blogger, website or business which audience has high chances to engage with Cryptolotto.
*
* @dev The sales is a person or a company, who is constantly looking for new influencers to join the Cryptolotto Referral System.
*
* @dev Each referral partner is getting his part of a commission from each player, who joined the game by following referral's 
* @dev custom link. A commission is sent to an Influencer and Sales right after a player joins the game. Players are bonded to 
* @dev referrals forever and cannot be removed from the Cryptolotto Referral System. Influencer and Sales are added to the 
* @dev Cryptolotto Referral System forever and cannot be removed from it. Influencer and Sales are getting their part of a 
* @dev commission as long as players, who followed Influencer's link, are playing the Cryptolotto.
**/
contract CryptolottoReferral {
    /**
    * @dev Write to log info about new partner.
    * 
    * @param _address Partner address.
    * @param _percent partner percent.
    * @param _time Time when partner was added.
    */
    event NewPartner(address indexed _address, uint _percent, uint _time);

    /**
    * @dev Write to log info about new sales partner.
    * 
    * @param _partnerAddress Partner address.
    * @param _salesPartnerAddress Sales partner address.
    * @param _percent Sales partner partner percent.
    * @param _time Time when partner was added.
    */
    event NewSalesPartner(
        address indexed _partnerAddress,
        address indexed _salesPartnerAddress,
        uint _percent,
        uint _time
    );

    /**
    * @dev Write to log info about new referral.
    *
    * @param _partner Partner address.
    * @param _referral Referral address.
    * @param _time Time when referral was added.
    */
    event NewReferral(address indexed _partner, address indexed _referral, uint _time);

    /**
    * @dev Write to log info about new game.
    *
    * @param _game Address of the game.
    * @param _time Time when game was added.
    */
    event NewGame(address _game, uint _time);

    /**
    * @dev Ownable contract.
    */ 
    iOwnable ownable;

    /**
    * @dev Store referrals.
    */
    mapping(address => address) referrals;

    /**
    * @dev Store cryptolotto partners.
    */ 
    mapping(address => uint8) partners;

    /**
    * @dev Store list of addresses(games) that can add referrals.
    */
    mapping(address => bool) allowedGames;

    /**
    * @dev Store sales partners.
    */
    mapping(address => address) salesPartners;

    /**
    * @dev Store cryptolotto sales partners percents.
    */
    mapping(address => mapping(address => uint8)) salesPartner;

    /**
    * @dev Initialize contract, Create ownable instances.
    *
    * @param owner The address of previously deployed ownable contract.
    */
    function CryptolottoReferral(address owner) public {
        ownable = iOwnable(owner);
    }

    /**
    * @dev Get partner by referral.
    *
    * @param player Referral address.
    */
    function getPartnerByReferral(address player) 
        public
        view
        returns (address)
    {
        return referrals[player];
    }

    /**
    * @dev Get partner percent.
    *
    * @param partner Partner address.
    */
    function getPartnerPercent(address partner)
        public 
        view 
        returns (uint8)
    {
        return partners[partner];
    }

    /**
    * @dev Get partner percent by referral.
    *
    * @param referral Refaral address.
    */
    function getPartnerPercentByReferral(address referral)
        public 
        view 
        returns (uint8)
    {
        address partner = getPartnerByReferral(referral);

        return getPartnerPercent(partner);
    }

    /**
    * @dev Get sales partner percent by partner address.
    *
    * @param partner Partner address.
    */
    function getSalesPartnerPercent(address partner)
        public 
        view 
        returns (uint8)
    {
        return salesPartner[salesPartners[partner]][partner];
    }

    /**
    * @dev Get sales partner address by partner address.
    *
    * @param partner Partner address.
    */
    function getSalesPartner(address partner)
        public 
        view 
        returns (address)
    {
        return salesPartners[partner];
    }

    /**
    * @dev Create partner.
    *
    * @param partner Partner address.
    * @param percent Partner percent.
    */
    function addPartner(address partner, uint8 percent) public {
        require(ownable.allowed(msg.sender));
        require(percent != 0 && partner != address(0));
        require(partners[partner] == 0);

        partners[partner] = percent;

        emit NewPartner(partner, percent, now);
    }

    /**
    * @dev Create sales partner.
    *
    * @param partner Partner address.
    * @param salesAddress Sales partner address.
    * @param percent Sales partner percent.
    */
    function addSalesPartner(address partner, address salesAddress, uint8 percent) public {
        require(ownable.allowed(msg.sender));
        require(percent != 0 && partner != address(0) && salesAddress != address(0));
        require(salesPartner[salesAddress][partner] == 0);
        require(getSalesPartnerPercent(partner) == 0);

        salesPartner[salesAddress][partner] = percent;
        salesPartners[partner] = salesAddress;

        emit NewSalesPartner(
            partner,
            salesAddress,
            percent,
            now
        );
    }

    /**
    * @dev Add new game which can create new referrals.
    *
    * @param game Game address.
    */ 
    function addGame(address game) public {
        require(ownable.allowed(msg.sender));
        require(game != address(0));

        allowedGames[game] = true;

        emit NewGame(game, now);
    }

    /**
    * @dev Add new referral.
    *
    * @param referral Referral address.
    * @param partner Partner address.
    */
    function addReferral(address partner, address referral) public {
        require(allowedGames[msg.sender]);
        require(partner != address(0) && referral != address(0));

        referrals[referral] = partner;

        emit NewReferral(partner, referral, now);
    }
}