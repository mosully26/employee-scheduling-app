<script lang="ts">
  let {
    start_date = $bindable(''),
    end_date = $bindable(''),
    reason = $bindable(''),
    loading = false,
    onsubmit
  }: {
    start_date?: string;
    end_date?: string;
    reason?: string;
    loading?: boolean;
    onsubmit?: () => void;
  } = $props();
</script>

<div class="rounded-2xl bg-white p-6 shadow-md">
  <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Request Time Off</h2>

  <div class="space-y-4">
    <div>
      <label for="timeoff-start-date" class="mb-2 block text-sm font-medium text-[#6b4f4f]">
        Start Date
      </label>
      <input
        id="timeoff-start-date"
        bind:value={start_date}
        type="date"
        class="w-full rounded-lg border p-3"
      />
    </div>

    <div>
      <label for="timeoff-end-date" class="mb-2 block text-sm font-medium text-[#6b4f4f]">
        End Date
      </label>
      <input
        id="timeoff-end-date"
        bind:value={end_date}
        type="date"
        class="w-full rounded-lg border p-3"
      />
    </div>

    <div>
      <label for="timeoff-reason" class="mb-2 block text-sm font-medium text-[#6b4f4f]">
        Reason
      </label>
      <textarea
        id="timeoff-reason"
        bind:value={reason}
        class="min-h-[120px] w-full rounded-lg border p-3"
        placeholder="Enter a short reason"
      ></textarea>
    </div>

    <button
      type="button"
      onclick={onsubmit}
      disabled={loading}
      class="w-full rounded-lg bg-[#6b4f4f] py-3 text-white hover:opacity-90 disabled:opacity-50"
    >
      {#if loading}
        Submitting...
      {:else}
        Submit Request
      {/if}
    </button>
  </div>
</div>