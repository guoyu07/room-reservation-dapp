pragma solidity ^0.4.18;


contract Booking {

    uint8 constant private MAX_SLOTS = 10;

    ////////////////////////////////////////////////////////////////////////////
    // Types
    ////////////////////////////////////////////////////////////////////////////

    struct Room {
        uint8 capacity;
        Slot[MAX_SLOTS] slots;
    }

    struct Slot {
        bool enabled;
        bytes16 data;
        mapping (uint32 => Reservation) reservations;
    }

    struct Reservation {
        address owner;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Modifiers
    ////////////////////////////////////////////////////////////////////////////

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier noEmptyRoom(uint32 roomId) {
        require(rooms[roomId].capacity > 0);
        _;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Attributes
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Max days in which you can book in advance
     */
    uint8 public maxDays;

    /**
    * Owner of the contract
    */
    address private owner;

    /**
     * Available rooms
     */
    mapping(uint32 => Room) private rooms;

    /**
     * List of IDs of available rooms
     */
    uint32[] private roomIds;

    ////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////

    event UpdateSlot(uint32 indexed roomId, uint8 indexed slot, bytes16 data);

    ////////////////////////////////////////////////////////////////////////////
    // Public admin methods
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Constructor where you can set the number of days in which you can book in
     * advance.
     *
     * @param   _maxDays    Days in which you can book in advance
     */
    function Booking(uint8 _maxDays) public {
        require(_maxDays > 0);

        maxDays = _maxDays;
        owner = msg.sender;
    }

    /**
     * Set the numer of days in which you can book in advance.
     *
     * @param   _maxDays    Number of days in which you can book in advance
     */
    function setMaxDays(uint8 _maxDays) public onlyOwner {
        require(_maxDays > 0);

        maxDays = _maxDays;
    }

    /**
     * Set room information.
     *
     * @param   roomId      ID of the room.
     * @param   capacity    Capacity of the room.
     */
    function setRoom(uint32 roomId, uint8 capacity) public onlyOwner {
        require(capacity > 0);

        if (rooms[roomId].capacity == 0) {
            roomIds.push(roomId);
        }

        rooms[roomId].capacity = capacity;
    }

    function getRoom(uint32 roomId, uint32 timestamp) public view
        returns (uint8 capacity, uint8[MAX_SLOTS] status, bytes16[MAX_SLOTS] data)
    {
        Room storage room = rooms[roomId];
        capacity = room.capacity;
        for (uint i = 0; i < room.slots.length; i++) {
            Slot storage slot = room.slots[i];
            if (!slot.enabled) {
                status[i] = 0;
                continue;
            }

            Reservation memory reservation =
                slot.reservations[getDay(timestamp)];
            status[i] = reservation.owner == address(0) ? 1 : 2;
            data[i] = slot.data;
        }

        return;
    }

    /**
    * Set a time slot data. Useful for store human readable information,
    * like "9:00 - 11:00".
    *
    * @param   roomId  ID of the room
    * @param   data    Data to store
    */
    function setSlot(uint32 roomId, uint8 slot, bytes16 data) public
        noEmptyRoom(roomId) onlyOwner
    {
        require(slot < MAX_SLOTS);

        rooms[roomId].slots[slot].enabled = true;
        rooms[roomId].slots[slot].data = data;

        UpdateSlot(roomId, slot, data);
    }


    function setSlots(uint32 roomId, bytes16[MAX_SLOTS] data) public
        noEmptyRoom(roomId) onlyOwner
    {
        for (uint8 i = 0; i < MAX_SLOTS; i++) {
            setSlot(roomId, i, data[i]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    // Public user methods
    ////////////////////////////////////////////////////////////////////////////

    /**
     * List all available rooms IDs.
     *
     * @return  List of rooms IDs
     */
    function listRooms() public view returns (uint32[]) {
        return roomIds;
    }

    /**
     * Books a room if available. Fails if the given day to book is "maxDays"
     * after the current day.
     *
     * @param   roomId  Room ID
     * @param   slotId  Slot
     * @param   timestamp     Day computed by dividing unix timestamp by 86400
     */
    function book(uint32 roomId, uint8 slotId, uint32 timestamp) public
        noEmptyRoom(roomId)
    {
        uint32 day = getDay(timestamp);
        uint32 currentDay = getCurrentDay();
        require(day >= currentDay && day <= currentDay + maxDays);
        require(rooms[roomId].slots[slotId].enabled);

        Room storage room = rooms[roomId];
        Slot storage slot = room.slots[slotId];
        Reservation storage reservation = slot.reservations[day];
        require(reservation.owner == address(0));

        reservation.owner = msg.sender;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Private methods
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Compute current day by dividing block timestamp by 86400.
     *
     * @return  Current day
     */
    function getCurrentDay() private view returns (uint32) {
        return uint32(block.timestamp / 86400);
    }

    function getDay(uint256 timestamp) private pure returns (uint32) {
        return uint32(timestamp / 86400);
    }
}
