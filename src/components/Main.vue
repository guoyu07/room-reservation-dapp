<template>
  <div>
    <q-layout>

      <q-toolbar
        slot="header"
        color="primary">
        <q-toolbar-title> Room Reservation Dapp </q-toolbar-title>
        <accounts @account-change="updateAccount" />
      </q-toolbar>

      <div class="layout-view">

        <div
          class="token"
          align="center">
          <h6> {{ (new Date()).toLocaleDateString() }} </h6>
        </div>

        <div class="row justify-center">
          <div
            class="col-md-auto"
            v-for="room in rooms"
            :key="room.id">

            <room
              :id="room.id"
              :booking="booking" />
          </div>
        </div>
      </div>

      <create-room :booking="booking"/>

      <q-toolbar slot="footer">
        <q-toolbar-title>
          <div class="pull-right">
            Contract address: {{ contractAddress }}
          </div>
        </q-toolbar-title>
      </q-toolbar>
    </q-layout>
  </div>
</template>

<script>
import {
  QLayout,
  QToolbar,
  QToolbarTitle,
  QBtn,
  QIcon,
  QList,
  QListHeader,
  QItem,
  QItemSide,
  QItemMain,
  QItemTile,
  QCard,
  QCardMain,
  QCardTitle,
  QCardMedia,
} from 'quasar';
import Booking from 'assets/Booking';

import Accounts from './accounts';
import Room from './rooms';
import CreateRoom from './create-rooms';

export default {
  name: 'Index',
  components: {
    QLayout,
    QToolbar,
    QToolbarTitle,
    QBtn,
    QIcon,
    QList,
    QListHeader,
    QItem,
    QItemSide,
    QItemMain,
    QItemTile,
    QCard,
    QCardMain,
    QCardTitle,
    QCardMedia,
    Accounts,
    Room,
    CreateRoom,
  },
  data() {
    return {
      booking: {},
      balance: 0,
      rooms: [],
      contractAddress: process.env.CONTRACT_ADDRESS,
    };
  },
  methods: {
    async updateAccount({ web3 }) {
      this.booking = new Booking(web3, process.env.CONTRACT_ADDRESS);

      const ids = await this.booking.listRoomsIds();
      this.rooms = ids.map(id => ({ id }));
    },
  },
};
</script>

<style lang="styl">

@import '~variables';

div.sala
  width 19em

div.token
  border-radius 0px
  margin-bottom 20px
  background-color $tertiary

.on-center > span > i
  margin-right 0px

.on-center
  margin-right 12px
</style>
