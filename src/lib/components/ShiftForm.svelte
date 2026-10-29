<script lang="ts">
  type Employee = {
    id: string | number;
    full_name?: string | null;
  };

  let {
    employees = [],
    employee_id = $bindable(''),
    title = $bindable(''),
    shift_role = $bindable(''),
    start_time = $bindable(''),
    end_time = $bindable(''),
    color = $bindable('#ff2d96'),
    notes = $bindable(''),
    onsubmit
  }: {
    employees?: Employee[];
    employee_id?: string;
    title?: string;
    shift_role?: string;
    start_time?: string;
    end_time?: string;
    color?: string;
    notes?: string;
    onsubmit?: () => void;
  } = $props();
</script>

<div class="rounded-2xl bg-white p-6 shadow-md">
  <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Create Shift</h2>

  <div class="space-y-4">
    <div>
      <label for="employee" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Employee</label>
      <select id="employee" bind:value={employee_id} class="w-full rounded-lg border p-3">
        <option value="">Select an employee</option>
        {#each employees as employee (employee.id)}
          <option value={employee.id}>{employee.full_name}</option>
        {/each}
      </select>
    </div>

    <div>
      <label for="shift-title" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Shift Title</label>
      <input
        id="shift-title"
        bind:value={title}
        type="text"
        class="w-full rounded-lg border p-3"
        placeholder="Example: Front Desk Shift"
      />
    </div>

    <div>
      <label for="shift-role" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Role</label>
      <input
        id="shift-role"
        bind:value={shift_role}
        type="text"
        class="w-full rounded-lg border p-3"
        placeholder="Example: Stylist"
      />
    </div>

    <div class="grid gap-4 md:grid-cols-2">
      <div>
        <label for="start-time" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Start Time</label>
        <input id="start-time" bind:value={start_time} type="datetime-local" class="w-full rounded-lg border p-3" />
      </div>

      <div>
        <label for="end-time" class="mb-2 block text-sm font-medium text-[#6b4f4f]">End Time</label>
        <input id="end-time" bind:value={end_time} type="datetime-local" class="w-full rounded-lg border p-3" />
      </div>
    </div>

    <div>
      <label for="shift-color" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Color</label>
      <input id="shift-color" bind:value={color} type="color" class="h-12 w-full rounded-lg border p-2" />
    </div>

    <div>
      <label for="shift-notes" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Notes</label>
      <textarea
        id="shift-notes"
        bind:value={notes}
        class="min-h-25 w-full rounded-lg border p-3"
        placeholder="Add any extra notes"
      ></textarea>
    </div>

    <button
      type="button"
      onclick={onsubmit}
      class="w-full rounded-lg bg-[#6b4f4f] py-3 text-white hover:opacity-90"
    >
      Save Shift
    </button>
  </div>
</div>