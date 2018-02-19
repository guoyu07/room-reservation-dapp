import BookingContract from '../../build/contracts/Booking.json';
import Web3 from 'web3';
import _ from 'lodash';

function fillData(data) {
  if (data === '0x') {
    data = '0x00';
  }

  return data;
}

function buildSlotFormatter(dataFormatter) {
  return ([status, data], i) => ({
    id: i,
    status: parseInt(status, 10),
    data: dataFormatter(data),
  });
}
//
// function buildRoomsFormatter(slotFormatter) {
//   return ([id, { capacity, status, data }]) => ({
//     id,
//     capacity,
//     slots: _.zip(status, data)
//       .map(slotFormatter)
//       .filter(({ data: d }) => d),
//   });
// }
//
const utf8DataFormatter = Web3.utils.hexToUtf8;
//
const slotFormatter = buildSlotFormatter(utf8DataFormatter);
//
// const roomsFormatter = buildRoomsFormatter(slotFormatter);

export default class Booking {
  constructor(web3, contractAddress) {
    this.web3 = new Web3(web3.currentProvider);
    this.contract = new this.web3.eth.Contract(
      BookingContract.abi,
      contractAddress,
    );
  }

  listRoomsIds() {
    return this.contract.methods.listRooms().call();
  }

  async getRoom(id, timestamp) {
    if (!timestamp) {
      timestamp = Date.now() / 1000;
    }

    const room = await this.contract.methods.getRoom(id, timestamp).call();

    return {
      id,
      capacity: room.capacity,
      slots: _.zip(room.status, room.data).map(slotFormatter),
    };
  }

  async setSlots(roomId, slots) {
    if (!Array.isArray(slots)) {
      return;
    }

    const from = await this.web3.eth.getAccounts();
    const slotsData = slots
      .map(({ data }) => data)
      .map(Web3.utils.utf8ToHex)
      .map(fillData);
    this.contract.methods.setSlots(roomId, slotsData).send({ from: from[0] });
  }

  async setRoom(roomId, capacity) {
    const from = await this.web3.eth.getAccounts();
    this.contract.methods.setRoom(roomId, capacity).send({ from: from[0] });
  }
}
