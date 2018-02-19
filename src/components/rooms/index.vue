<template lang="html">
  <div>
    <q-card class="room">
      <q-card-title>

        Room {{ room.id }}

        <div
          slot="right"
          class="row items-center">
          <config-room
            :room="room"
            :booking="booking" />
          <q-icon name="people" /> &nbsp; {{ room.capacity }}
        </div>
      </q-card-title>

      <q-list>
        <q-item v-if="slots.length === 0">
          <q-item-main>
            <q-item-tile
              color="faded"
              align="center">
              No slot available
            </q-item-tile>
          </q-item-main>
        </q-item>

        <q-item
          v-for="slot in slots"
          :key="slot.id">

          <q-item-side
            v-if="slot.status === 0"
            icon="event_busy"
            color="faded" />
          <q-item-side
            v-else-if="slot.status === 1"
            icon="event_available"
            color="positive" />
          <q-item-side
            v-else
            icon="event_busy"
            color="negative" />

          <q-item-main>
            <q-item-tile> {{ slot.data }} </q-item-tile>
          </q-item-main>

          <q-item-side right>
            <q-btn
              icon="access_time"
              small
              round
              :class="{ disabled : slot.status !== 1 }" />
          </q-item-side>
        </q-item>
      </q-list>
    </q-card>
  </div>
</template>

<script>
import {
  QList,
  QListHeader,
  QCard,
  QCardMain,
  QCardTitle,
  QCardMedia,
  QBtn,
  QIcon,
  QItem,
  QItemSide,
  QItemMain,
  QItemTile,
} from 'quasar';
import ConfigRoom from './ConfigRoom';

export default {
  name: 'Room',

  components: {
    QList,
    QListHeader,
    QCard,
    QCardMain,
    QCardTitle,
    QCardMedia,
    QBtn,
    QIcon,
    QItem,
    QItemSide,
    QItemMain,
    QItemTile,
    ConfigRoom,
  },

  props: {
    id: {
      required: true,
      type: String,
    },
    booking: {
      required: true,
      type: Object,
    },
  },

  data() {
    return {
      room: {},
    };
  },

  computed: {
    slots() {
      if (!this.room.slots) {
        return [];
      }

      return this.room.slots.filter(slot => slot.data);
    },
  },

  async mounted() {
    const id = parseInt(this.id);

    if (isNaN(id)) {
      return;
    }

    this.room = await this.booking.getRoom(id);
  },
};
</script>

<style lang="styl">

@import '~variables';

div.room
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
