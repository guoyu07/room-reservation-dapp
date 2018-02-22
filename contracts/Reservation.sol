pragma solidity ^0.4.18;


contract Reservation {

    // Max reservation slots per room
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
        mapping (uint32 => address) reservations;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Modifiers
    ////////////////////////////////////////////////////////////////////////////

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier noEmptyRoom(uint32 roomId) {
        require(rooms[roomId].capacity != 0);
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
     * Available rooms
     */
    uint32[] private roomIds;
    mapping(uint32 => Room) private rooms;

    /**
     * Owner of the contract
     */
    address private owner;

    ////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////

    event MaxDaysUpdated(uint8 maxDays);
    event RoomUpdated(uint32 indexed roomId);
    event SlotUpdated(uint32 indexed roomId, uint8 indexed slot);
    event SlotReserved(uint32 indexed roomId, uint8 indexed slot, address user);

    ////////////////////////////////////////////////////////////////////////////
    // Constructor
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Constructor where you can set the number of days in which you can book in
     * advance.
     *
     * @param   _maxDays    Days in which you can book in advance
     */
    function Reservation(uint8 _maxDays) public {
        maxDays = _maxDays;
        owner = msg.sender;
    }

    ////////////////////////////////////////////////////////////////////////////
    // External admin methods
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Set the numer of days in which you can book in advance.
     *
     * @param   _maxDays    Number of days in which you can book in advance
     */
    function setMaxDays(uint8 _maxDays) external onlyOwner {
        maxDays = _maxDays;
        MaxDaysUpdated(_maxDays);
    }

    /**
     * Update room information. If the room does not exists, create a new one.
     *
     * @param   roomId      ID of the room.
     * @param   capacity    Capacity of the room.
     */
    function updateRoom(uint32 roomId, uint8 capacity) external onlyOwner {
        require(capacity != 0);

        // If capacity == 0, the room does not exists
        if (rooms[roomId].capacity == 0) {
            roomIds.push(roomId);
        }

        rooms[roomId].capacity = capacity;
        RoomUpdated(roomId);
    }

    /**
     * Update multiple slots at once.
     *
     * @param   roomId  ID of the room
     * @param   data    Data to store
     */
    function populateSlots(uint32 roomId, bytes16[MAX_SLOTS] data) external
        noEmptyRoom(roomId) onlyOwner
    {
        for (uint8 i = 0; i < MAX_SLOTS; i++) {
            setSlotData(roomId, i, data[i]);
            if (data[i].length > 0) {
                setSlotStatus(roomId, i, true);
            }
        }

        RoomUpdated(roomId);
    }

    ////////////////////////////////////////////////////////////////////////////
    // External user methods
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Reserve a room if available. Fail if the given day to book is "maxDays"
     * after the current day.
     *
     * @param   roomId        Room ID
     * @param   slotId        Slot
     * @param   timestamp     Day computed by dividing unix timestamp by 86400
     */
    function reserve(uint32 roomId, uint8 slotId, uint32 timestamp) external
        noEmptyRoom(roomId)
    {
        uint32 reservationDay = getDay(timestamp);
        uint32 currentDay = getDay(block.timestamp);
        require(
            reservationDay >= currentDay &&
            reservationDay <= currentDay + maxDays
        );

        Room storage room = rooms[roomId];
        Slot storage slot = room.slots[slotId];
        require(
            slot.enabled &&
            slot.reservations[reservationDay] == address(0)
        );

        slot.reservations[reservationDay] = msg.sender;

        SlotReserved(roomId, slotId, msg.sender);
    }

    /**
     * Cancel a reservation.
     *
     * @param   roomId        Room ID
     * @param   slotId        Slot
     * @param   timestamp     Day computed by dividing unix timestamp by 86400
     */
    function cancel(uint32 roomId, uint8 slotId, uint32 timestamp) external
        noEmptyRoom(roomId)
    {
        uint32 reservationDay = getDay(timestamp);
        uint32 currentDay = getDay(block.timestamp);
        require(
            reservationDay >= currentDay &&
            reservationDay <= currentDay + maxDays
        );

        Room storage room = rooms[roomId];
        Slot storage slot = room.slots[slotId];
        require(slot.reservations[reservationDay] == msg.sender);

        slot.reservations[reservationDay] = address(0);

        SlotReserved(roomId, slotId, address(0));
    }

    /**
     * List all available rooms IDs.
     *
     * @return  List of rooms IDs
     */
    function listRooms() external view returns (uint32[]) {
        return roomIds;
    }

    /**
     * Get room information. Shows the reservation status for a given timestamp.
     *
     * @param   roomId      ID of the room.
     * @param   timestamp   Used to show reservation status of the room.
     * @return  capacity    Capacity of the room.
     * @return  status      Reservation status for every slot:
     *                        0: disable | 1: available | 2: reserved
     * @return  data        Information about the slot.
     */
    function getRoom(
        uint32 roomId,
        uint32 timestamp
    ) external view noEmptyRoom(roomId) returns (
        uint8 capacity,
        uint8[MAX_SLOTS] status,
        bytes16[MAX_SLOTS] data
    ) {
        Room storage room = rooms[roomId];
        capacity = room.capacity;
        for (uint i = 0; i < MAX_SLOTS; i++) {
            Slot storage slot = room.slots[i];
            data[i] = slot.data;

            if (!slot.enabled) {
                status[i] = 0;
                continue;
            }

            status[i] =
                slot.reservations[getDay(timestamp)] == address(0)
                ? 1
                : 2;
        }

        return;
    }

    ////////////////////////////////////////////////////////////////////////////
    // Public methods
    ////////////////////////////////////////////////////////////////////////////

    /**
    * Set a slot data. Useful for store human readable information,
    * like "9:00 - 11:00".
    *
    * @param   roomId  ID of the room
    * @param   slot    Slot to update
    * @param   data    Data to store
    */
    function setSlotData(uint32 roomId, uint8 slot, bytes16 data) public
        noEmptyRoom(roomId) onlyOwner
    {
        require(slot < MAX_SLOTS);

        rooms[roomId].slots[slot].data = data;

        SlotUpdated(roomId, slot);
    }

    /**
    * Set a slot status. Slots can be disabled to avoid further reservations.
    *
    * @param   roomId  ID of the room
    * @param   slot    Slot to update
    * @param   status  Set to false for disable reservations
    */
    function setSlotStatus(uint32 roomId, uint8 slot, bool status) public
        noEmptyRoom(roomId) onlyOwner
    {
        require(slot < MAX_SLOTS);

        rooms[roomId].slots[slot].enabled = status;

        SlotUpdated(roomId, slot);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Private methods
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Get current day by dividing timestamp by 86400 (number of seconds
     * in a day).
     *
     * @param   timestamp     Unix timestamp to get the day from.
     * @return  Current day
     */
    function getDay(uint256 timestamp) private pure returns (uint32) {
        return uint32(timestamp / 86400);
    }
}
