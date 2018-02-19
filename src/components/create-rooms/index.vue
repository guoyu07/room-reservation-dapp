<template lang="html">
  <div>

    <q-fixed-position
      corner="bottom-right"
      :offset="[18, 18]">
      <q-btn
        round
        color="primary"
        @click="openModal">
        <q-icon name="add" />
      </q-btn>
    </q-fixed-position>

    <q-modal
      ref="basicModal"
      class="config-room-modal">

      <h5>Create new room</h5>

      <q-input
        v-model="roomIdStr"
        stack-label="Room ID" />
      <q-input
        v-model="roomCapacityStr"
        stack-label="Room capacity" />

      <div class="pull-right">
        <q-btn
          class="pull-right"
          color="primary"
          @click="createRoom"
        >
          Create
        </q-btn>
      </div>
    </q-modal>

  </div>
</template>

<script>
import { QModal, QIcon, QInput, QBtn, QFixedPosition } from 'quasar';

export default {
  name: 'CreateRoom',

  components: {
    QInput,
    QBtn,
    QFixedPosition,
    QIcon,
    QModal,
  },

  props: {
    booking: {
      required: true,
      type: Object,
    },
  },

  data() {
    return {
      roomIdStr: null,
      roomCapacityStr: null,
      modal: {
        label: 'Modal',
        ref: 'basicModal',
      },
    };
  },

  computed: {
    // TODO: Use vue validator
    roomId() {
      const number = parseInt(this.roomIdStr);

      if (isNaN(number)) {
        return null;
      }

      return number;
    },
    // TODO: Use vue validator
    roomCapacity() {
      const number = parseInt(this.roomCapacityStr);

      if (isNaN(number)) {
        return null;
      }

      return number;
    },
  },

  methods: {
    openModal() {
      this.$refs[this.modal.ref].open();
    },

    createRoom() {
      if (this.roomId && this.roomCapacity) {
        this.booking.setRoom(this.roomId, this.roomCapacity);
      }

      // TODO show error

      this.$refs[this.modal.ref].close();
    },
  },
};
</script>


<style lang="css">
.config-room-modal > .modal-content {
  width: 10em;
}

.slots-content {
  margin-top: 20px;
  margin-bottom: 20px;
}
</style>
