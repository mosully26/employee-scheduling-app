<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import { SvelteDate } from 'svelte/reactivity';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import ScheduleCalendar from '$lib/components/ScheduleCalendar.svelte';

  type Profile = Record<string, string | number | boolean | null | undefined>;

  type Shift = {
    id?: string | number;
    title?: string;
    start_time?: string;
    end_time?: string;
    shift_role?: string;
    color?: string | null;
  };

  let profile = $state<Profile | null>(null);
  let shifts = $state<Shift[]>([]);
  let loading = $state(true);
  let error = $state('');
  let sidebarOpen = $state(false);
  let view = $state<'day' | 'week' | 'month'>('month');

  onMount(async () => {
    try {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!user) {
        window.location.href = '/login';
        return;
      }

      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id);

      if (profileError) {
        error = profileError.message;
        return;
      }

      profile = Array.isArray(profileData) ? profileData[0] : profileData;

      const { data, error: shiftsError } = await supabase
        .from('shifts')
        .select('*')
        .eq('employee_id', user.id)
        .order('start_time', { ascending: true });

      if (shiftsError) {
        error = shiftsError.message;
        return;
      }

      shifts = data ?? [];
    } catch (err) {
      console.error(err);
      error = 'Something went wrong loading your schedule.';
    } finally {
      loading = false;
    }
  });

  function sameDay(dateValue: string | undefined, compareDate: Date) {
    if (!dateValue) return false;

    return getDateKey(dateValue) === getDateKey(compareDate);
  }

  function getDateKey(value: string | Date) {
    if (typeof value === 'string') return value.slice(0, 10);

    return `${value.getFullYear()}-${String(value.getMonth() + 1).padStart(2, '0')}-${String(value.getDate()).padStart(2, '0')}`;
  }

  function inNextTenDays(dateValue: string | undefined) {
    if (!dateValue) return false;

    const start = new SvelteDate();
    start.setHours(0, 0, 0, 0);

    const end = new SvelteDate(start);
    end.setDate(start.getDate() + 9);
    end.setHours(23, 59, 59, 999);

    const dateKey = getDateKey(dateValue);
    return dateKey >= getDateKey(start) && dateKey <= getDateKey(end);
  }

  function inCurrentMonth(dateValue: string | undefined) {
    if (!dateValue) return false;

    const now = new SvelteDate();
    return getDateKey(dateValue).slice(0, 7) === getDateKey(now).slice(0, 7);
  }

  const filteredShifts = $derived.by(() => {
    const now = new Date();

    if (view === 'day') {
      return shifts.filter((shift) => sameDay(shift.start_time, now));
    }

    if (view === 'month') {
      return shifts.filter((shift) => inCurrentMonth(shift.start_time));
    }

    return shifts.filter((shift) => inNextTenDays(shift.start_time));
  });
</script>

<div class="min-h-screen bg-[#fff9f8]">
  <Sidebar profile={profile} bind:isOpen={sidebarOpen} />

  <div class="md:ml-72">
    <div class="sticky top-0 z-20 border-b border-[#efd9dd] bg-white/90 backdrop-blur">
      <div class="flex items-center justify-between px-4 py-4 md:px-6">
        <div class="flex items-center gap-3">
          <button
            type="button"
            class="rounded-lg bg-[#f7edee] px-3 py-2 text-[#6b4f4f] md:hidden"
            onclick={() => (sidebarOpen = true)}
          >
            Menu
          </button>

          <div>
            <p class="text-lg font-bold text-[#6b4f4f]">Schedule</p>
            <p class="text-sm text-[#9c7b7b]">View your monthly calendar and scheduled shifts</p>
          </div>
        </div>

        <div class="hidden gap-2 md:flex">
          <button
            type="button"
            onclick={() => (view = 'day')}
            class={`rounded-lg px-4 py-2 ${
              view === 'day'
                ? 'bg-[#ff2d96] text-white'
                : 'bg-[#f7edee] text-[#6b4f4f]'
            }`}
          >
            Day
          </button>

          <button
            type="button"
            onclick={() => (view = 'week')}
            class={`rounded-lg px-4 py-2 ${
              view === 'week'
                ? 'bg-[#ff2d96] text-white'
                : 'bg-[#f7edee] text-[#6b4f4f]'
            }`}
          >
            10 Days
          </button>

          <button
            type="button"
            onclick={() => (view = 'month')}
            class={`rounded-lg px-4 py-2 ${
              view === 'month'
                ? 'bg-[#ff2d96] text-white'
                : 'bg-[#f7edee] text-[#6b4f4f]'
            }`}
          >
            Month
          </button>
        </div>
      </div>
    </div>

    <main class="p-4 md:p-6">
      {#if loading}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-[#9c7b7b]">Loading schedule...</p>
        </div>
      {:else if error}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-red-500">{error}</p>
        </div>
      {:else}
        <div class="space-y-6">
          <div class="rounded-3xl bg-white p-6 shadow-md md:hidden">
            <p class="mb-3 text-sm font-medium text-[#6b4f4f]">Choose a view</p>
            <div class="flex gap-2">
              <button
                type="button"
                onclick={() => (view = 'day')}
                class={`flex-1 rounded-lg px-4 py-2 ${
                  view === 'day'
                    ? 'bg-[#ff2d96] text-white'
                    : 'bg-[#f7edee] text-[#6b4f4f]'
                }`}
              >
                Day
              </button>

              <button
                type="button"
                onclick={() => (view = 'week')}
                class={`flex-1 rounded-lg px-4 py-2 ${
                  view === 'week'
                    ? 'bg-[#ff2d96] text-white'
                    : 'bg-[#f7edee] text-[#6b4f4f]'
                }`}
              >
                10 Days
              </button>

              <button
                type="button"
                onclick={() => (view = 'month')}
                class={`flex-1 rounded-lg px-4 py-2 ${
                  view === 'month'
                    ? 'bg-[#ff2d96] text-white'
                    : 'bg-[#f7edee] text-[#6b4f4f]'
                }`}
              >
                Month
              </button>
            </div>
          </div>

          <ScheduleCalendar shifts={filteredShifts} {view} />
        </div>
      {/if}
    </main>
  </div>
</div>