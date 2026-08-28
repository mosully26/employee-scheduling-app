<script lang="ts">
  let {
    shifts = [],
    view = 'week'
  }: {
    shifts?: any[];
    view?: 'day' | 'week' | 'month' | string;
  } = $props();

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString([], {
      weekday: 'short',
      month: 'short',
      day: 'numeric'
    });
  }

  function formatTime(date: string) {
    return new Date(date).toLocaleTimeString([], {
      hour: 'numeric',
      minute: '2-digit'
    });
  }
</script>

<div class="rounded-2xl bg-white p-6 shadow-md">
  <div class="mb-4 flex items-center justify-between">
    <div>
      <h3 class="text-xl font-bold text-[#6b4f4f]">Schedule</h3>
      <p class="text-sm capitalize text-[#9c7b7b]">{view} view</p>
    </div>
  </div>

  {#if shifts.length === 0}
    <p class="text-[#9c7b7b]">No scheduled shifts to display.</p>
  {:else}
    <div class="space-y-4">
      {#each shifts as shift}
        <div
          class="rounded-xl border border-[#ead8d8] p-4"
          style={`border-left: 6px solid ${shift.color || '#ff2d96'}`}
        >
          <div class="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
            <div>
              <h4 class="font-semibold text-[#6b4f4f]">{shift.title}</h4>
              <p class="text-sm text-[#9c7b7b]">{formatDate(shift.start_time)}</p>
            </div>

            <div class="text-sm text-[#7d6161]">
              {formatTime(shift.start_time)} - {formatTime(shift.end_time)}
            </div>
          </div>

          {#if shift.shift_role}
            <p class="mt-2 text-sm text-[#7d6161]">Role: {shift.shift_role}</p>
          {/if}

          {#if shift.notes}
            <p class="mt-1 text-sm text-[#7d6161]">{shift.notes}</p>
          {/if}
        </div>
      {/each}
    </div>
  {/if}
</div>