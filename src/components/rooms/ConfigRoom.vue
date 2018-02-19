<template lang="html">
  <div>
    <q-btn
      class="on-center"
      icon="settings"
      @click="openConfig()"
      flat />

    <q-modal
      class="config-room-modal"
      ref="basicModal">
      <div class="row">
        <h5>Room configuration</h5>
      </div>

      <div class="slots-content">
        <div
          v-for="slot in room.slots"
          :key="slot.id"
        >
          <q-field
            :count="16"
            :label="`Slot ${slot.id+1}`">
            <q-input
              max-length="16"
              v-model="slot.data" />
          </q-field>
        </div>
      </div>

      <div class="row pull-right">
        <q-btn
          class="pull-right"
          color="primary"
          @click="updateConfig()"
        >
          Save
        </q-btn>
      </div>
    </q-modal>
  </div>
</template>

<script>
import { QBtn, QField, QInput, QModal } from 'quasar';

export default {
  name: 'SlotSettings',

  components: {
    QBtn,
    QField,
    QInput,
    QModal,
  },

  props: {
    room: {
      type: Object,
      required: true,
    },
    booking: {
      type: Object,
      required: true,
    },
  },

  data() {
    return {
      modal: {
        label: 'Modal',
        ref: 'basicModal',
      },
    };
  },

  methods: {
    openConfig() {
      this.$refs[this.modal.ref].open();
    },

    updateConfig() {
      this.booking.setSlots(this.room.id, this.room.slots);
      this.$refs[this.modal.ref].close();
    },
  },
};
</script>

<style lang="css">
.config-room-modal > .modal-content {
  width: 30em;
}

.slots-content {
  margin-top: 20px;
  margin-bottom: 20px;
}
</style>
