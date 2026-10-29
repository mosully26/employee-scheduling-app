<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import { SvelteDate, SvelteMap } from 'svelte/reactivity';
  import Sidebar from '$lib/components/Sidebar.svelte';

  type Profile = {
    id?: string;
    full_name?: string;
    email?: string;
    role?: string;
    profile_image_url?: string;
    job_title?: string;
  };

  type Employee = {
    id?: string;
    full_name?: string;
    email?: string;
    role?: string;
  };

  type ShiftRow = {
    id?: string;
    title?: string;
    employee_id?: string;
    shift_role?: string;
    start_time?: string;
    end_time?: string;
    color?: string | null;
  };

  type RequestRow = {
    id?: string;
    employee_id?: string;
    start_date?: string;
    end_date?: string;
    status?: string;
    reason?: string;
  };

  type AnnouncementRow = {
    id?: string;
    title?: string;
    message?: string;
    created_at?: string;
  };

  let profile = $state<Profile | null>(null);
  let employees = $state<Employee[]>([]);
  let shifts = $state<ShiftRow[]>([]);
  let requests = $state<RequestRow[]>([]);
  let announcements = $state<AnnouncementRow[]>([]);

  let loading = $state(true);
  let error = $state('');
  let success = $state('');
  let authorized = $state(false);
  let sidebarOpen = $state(false);
  let calendarMonth = $state(new Date(new Date().getFullYear(), new Date().getMonth(), 1));

  let employee_id = $state('');
  let title = $state('');
  let shift_role = $state('');
  let start_time = $state('');
  let end_time = $state('');
  let color = $state('#ff2d96');
  let notes = $state('');

  let announcement_title = $state('');
  let announcement_message = $state('');

  const selectableEmployees = $derived.by(() => {
    const everyone = profile ? [...employees, profile] : employees;
    const uniqueEmployees = new SvelteMap<string, Employee>();

    for (const employee of everyone) {
      if (employee.id) uniqueEmployees.set(employee.id, employee);
    }

    return [...uniqueEmployees.values()].sort((first, second) =>
      (first.full_name ?? '').localeCompare(second.full_name ?? '')
    );
  });

  onMount(async () => {
    await loadAdminData();
  });

  async function loadAdminData() {
  loading = true;
  error = '';
  success = '';
  authorized = false;

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
      .eq('id', user.id)
      .single();

    if (profileError) {
      error = profileError.message;
      return;
    }

    if (!profileData || (profileData.role !== 'MANAGER' && profileData.role !== 'ADMIN')) {
      window.location.href = '/dashboard';
      return;
    }

    profile = profileData
      ? {
          ...profileData,
          full_name: profileData.full_name ?? undefined,
          email: profileData.email ?? undefined,
          role: profileData.role ?? undefined,
          profile_image_url: profileData.profile_image_url ?? undefined,
          job_title: profileData.job_title ?? undefined
        }
      : null;
    authorized = true;

    const { data: employeeData, error: employeeError } = await supabase
      .from('profiles')
      .select('*')
      .order('full_name', { ascending: true });

    if (employeeError) {
      error = employeeError.message;
      return;
    }

    employees = employeeData ?? [];

    const { data: shiftData, error: shiftError } = await supabase
      .from('shifts')
      .select('*')
      .order('start_time', { ascending: true });

    if (shiftError) {
      error = shiftError.message;
      return;
    }

    shifts = shiftData ?? [];

    const { data: requestData, error: requestError } = await supabase
      .from('time_off_requests')
      .select('*')
      .order('created_at', { ascending: false });

    if (requestError) {
      error = requestError.message;
      return;
    }

    requests = requestData ?? [];

    const { data: announcementData, error: announcementError } = await supabase
      .from('announcements')
      .select('*')
      .order('created_at', { ascending: false });

    if (announcementError) {
      error = announcementError.message;
      return;
    }

    announcements = announcementData ?? [];
  } catch (err) {
    console.error(err);
    error = 'Something went wrong loading the admin page.';
  } finally {
    loading = false;
  }
}
  async function createShift() {
    error = '';
    success = '';

    try {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!user) {
        window.location.href = '/login';
        return;
      }

      if (!employee_id || !title || !start_time || !end_time) {
        error = 'Please fill in employee, title, start time, and end time.';
        return;
      }

      const createdShiftId = crypto.randomUUID();
      const createdShift: ShiftRow = {
        id: createdShiftId,
        employee_id,
        title,
        shift_role,
        start_time,
        end_time,
        color
      };

      const { error: insertError } = await supabase.from('shifts').insert([
        {
          id: createdShiftId,
          employee_id,
          title,
          shift_role,
          start_time,
          end_time,
          color,
          notes,
          created_by: user.id
        }
      ]);

      if (insertError) {
        error = insertError.message;
        return;
      }

      success = 'Shift created successfully.';
      employee_id = '';
      title = '';
      shift_role = '';
      start_time = '';
      end_time = '';
      color = '#ff2d96';
      notes = '';

      await loadAdminData();

      if (!shifts.some((shift) =>
        shift.employee_id === createdShift.employee_id &&
        shift.start_time === createdShift.start_time &&
        shift.end_time === createdShift.end_time
      )) {
        shifts = [...shifts, createdShift];
      }
    } catch (err) {
      console.error(err);
      error = 'Something went wrong creating the shift.';
    }
  }

  async function moveShift(shiftId: string | undefined, assignedEmployeeId: string, day: Date) {
    error = '';
    success = '';

    if (isPastDay(day)) {
      error = 'Past shifts cannot be moved.';
      return;
    }

    if (!shiftId || !assignedEmployeeId) {
      error = 'A shift and assigned person are required.';
      return;
    }

    const { error: updateError } = await supabase
      .from('shifts')
      .update({ employee_id: assignedEmployeeId })
      .eq('id', shiftId);

    if (updateError) {
      error = updateError.message;
      return;
    }

    const { data: updatedShift, error: verifyError } = await supabase
      .from('shifts')
      .select('employee_id')
      .eq('id', shiftId)
      .maybeSingle();

    if (verifyError) {
      error = verifyError.message;
      return;
    }

    if (!updatedShift || updatedShift.employee_id !== assignedEmployeeId) {
      error = 'The assignment was not saved. Run supabase/shifts-admin-rls.sql in Supabase to enable moving shifts.';
      return;
    }

    shifts = shifts.map((shift) =>
      shift.id === shiftId ? { ...shift, employee_id: assignedEmployeeId } : shift
    );
    success = 'Shift assignment updated.';
  }

  async function removeShift(shiftId: string | undefined, day: Date) {
    error = '';
    success = '';

    if (isPastDay(day)) {
      error = 'Past shifts cannot be removed.';
      return;
    }

    if (!shiftId) {
      error = 'This shift has no database id. Refresh the page before removing it.';
      return;
    }

    if (!window.confirm('Remove this scheduled shift?')) return;

    const { error: deleteError } = await supabase
      .from('shifts')
      .delete()
      .eq('id', shiftId);

    if (deleteError) {
      error = deleteError.message;
      return;
    }

    const { data: remainingShift, error: verifyError } = await supabase
      .from('shifts')
      .select('id')
      .eq('id', shiftId)
      .maybeSingle();

    if (verifyError) {
      error = verifyError.message;
      return;
    }

    if (remainingShift) {
      error = 'The shift is still saved. Run supabase/shifts-admin-rls.sql in Supabase to enable shift removal.';
      return;
    }

    shifts = shifts.filter((shift) => shift.id !== shiftId);
    success = 'Scheduled shift removed.';
  }

  function handleShiftAssignmentChange(event: Event, shiftId: string | undefined, day: Date) {
    const select = event.currentTarget as HTMLSelectElement;
    void moveShift(shiftId, select.value, day);
  }

  async function updateRequestStatus(id: string | undefined, status: 'APPROVED' | 'DENIED') {
    error = '';
    success = '';

    if (!id) {
      error = 'Request id is missing.';
      return;
    }

    try {
      const { error: updateError } = await supabase
        .from('time_off_requests')
        .update({ status })
        .eq('id', id);

      if (updateError) {
        error = updateError.message;
        return;
      }

      success = `Request ${status.toLowerCase()}.`;
      await loadAdminData();
    } catch (err) {
      console.error(err);
      error = 'Something went wrong updating the request.';
    }
  }

  async function createAnnouncement() {
    error = '';
    success = '';

    try {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!user) {
        window.location.href = '/login';
        return;
      }

      if (!announcement_title || !announcement_message) {
        error = 'Please enter both a title and message.';
        return;
      }

      const { error: insertError } = await supabase.from('announcements').insert([
        {
          title: announcement_title,
          message: announcement_message,
          created_by: user.id
        }
      ]);

      if (insertError) {
        error = insertError.message;
        return;
      }

      success = 'Announcement posted successfully.';
      announcement_title = '';
      announcement_message = '';

      await loadAdminData();
    } catch (err) {
      console.error(err);
      error = 'Something went wrong posting the announcement.';
    }
  }

  async function deleteAnnouncement(id: string | undefined) {
    error = '';
    success = '';

    if (!id) {
      error = 'Announcement id is missing.';
      return;
    }

    if (!window.confirm('Delete this announcement?')) return;

    try {
      const { error: deleteError } = await supabase
        .from('announcements')
        .delete()
        .eq('id', id);

      if (deleteError) {
        error = deleteError.message;
        return;
      }

      const { data: remainingAnnouncement, error: verifyError } = await supabase
        .from('announcements')
        .select('id')
        .eq('id', id)
        .maybeSingle();

      if (verifyError) {
        error = verifyError.message;
        return;
      }

      if (remainingAnnouncement) {
        error = 'The announcement is still in Supabase. Apply the announcement delete policy in Supabase.';
        return;
      }

      announcements = announcements.filter((announcement) => announcement.id !== id);
      success = 'Announcement deleted successfully.';
    } catch (err) {
      console.error(err);
      error = 'Something went wrong deleting the announcement.';
    }
  }

  function formatDate(date?: string) {
    if (!date) return '—';

    const datePart = date.slice(0, 10);
    const [year, month, day] = datePart.split('-').map(Number);
    if (year && month && day) {
      return new Date(year, month - 1, day).toLocaleDateString([], {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      });
    }

    return new Date(date).toLocaleDateString([], {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  }

  function formatTime(date?: string) {
    if (!date) return '—';

    const timePart = date.split('T')[1]?.slice(0, 5);
    if (timePart) {
      const [hours, minutes] = timePart.split(':').map(Number);
      if (!Number.isNaN(hours) && !Number.isNaN(minutes)) {
        const time = new SvelteDate();
        time.setHours(hours, minutes, 0, 0);
        return time.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
      }
    }

    return new Date(date).toLocaleTimeString([], {
      hour: 'numeric',
      minute: '2-digit'
    });
  }

  function statusClasses(status?: string) {
    if (status === 'APPROVED') return 'bg-green-100 text-green-700';
    if (status === 'DENIED') return 'bg-red-100 text-red-700';
    return 'bg-yellow-100 text-yellow-700';
  }

  function getAssignedPersonName(id?: string) {
    if (!id) return 'Unassigned';

    const employee = employees.find((person) => person.id === id);
    const fullName = employee?.full_name?.trim();
    const isRoleLabel = fullName && ['ADMIN', 'MANAGER', 'EMPLOYEE'].includes(fullName.toUpperCase());

    return !isRoleLabel && fullName ? fullName : employee?.email ?? 'Assigned team member';
  }

  const monthDays = $derived.by(() => {
    const year = calendarMonth.getFullYear();
    const month = calendarMonth.getMonth();
    const firstDay = new Date(year, month, 1);
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const days: (Date | null)[] = Array.from({ length: firstDay.getDay() }, () => null);

    for (let day = 1; day <= daysInMonth; day += 1) {
      days.push(new Date(year, month, day));
    }

    return days;
  });

  const calendarMonthLabel = $derived(
    calendarMonth.toLocaleDateString([], { month: 'long', year: 'numeric' })
  );

  function shiftsForDay(day: Date) {
    const dayKey = `${day.getFullYear()}-${String(day.getMonth() + 1).padStart(2, '0')}-${String(day.getDate()).padStart(2, '0')}`;

    return shifts.filter((shift) => {
      if (!shift.start_time) return false;

      return shift.start_time.slice(0, 10) === dayKey;
    });
  }

  function isToday(day: Date) {
    const today = new Date();
    return (
      today.getFullYear() === day.getFullYear() &&
      today.getMonth() === day.getMonth() &&
      today.getDate() === day.getDate()
    );
  }

  function isPastDay(day: Date) {
    const today = new SvelteDate();
    today.setHours(0, 0, 0, 0);
    const calendarDay = new SvelteDate(day);
    calendarDay.setHours(0, 0, 0, 0);
    return calendarDay < today;
  }

  function changeCalendarMonth(offset: number) {
    calendarMonth = new Date(calendarMonth.getFullYear(), calendarMonth.getMonth() + offset, 1);
  }
</script>

<div class="min-h-screen bg-[#fff9f8]">
  <Sidebar
    profile={profile
      ? {
          full_name: profile.full_name ?? undefined,
          role: profile.role ?? undefined,
          job_title: profile.job_title ?? undefined,
          profile_image_url: profile.profile_image_url ?? undefined
        }
      : null}
    bind:isOpen={sidebarOpen}
  />

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
            <p class="text-lg font-bold text-[#6b4f4f]">Admin</p>
            <p class="text-sm text-[#9c7b7b]">Manage employees, shifts, and announcements</p>
          </div>
        </div>
      </div>
    </div>

    <main class="p-4 md:p-6">
      {#if loading}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-[#9c7b7b]">Loading admin page...</p>
        </div>
      {:else if authorized}
        <div class="space-y-6">
          {#if error}
            <div class="rounded-2xl bg-red-50 p-4 text-red-600">{error}</div>
          {/if}

          {#if success}
            <div class="rounded-2xl bg-green-50 p-4 text-green-700">{success}</div>
          {/if}

          <section class="grid gap-4 md:grid-cols-4">
            <div class="rounded-2xl bg-white p-5 shadow-md">
              <p class="text-sm text-[#9c7b7b]">Employees</p>
              <h2 class="mt-1 text-2xl font-bold text-[#6b4f4f]">{employees.length}</h2>
            </div>

            <div class="rounded-2xl bg-white p-5 shadow-md">
              <p class="text-sm text-[#9c7b7b]">Shifts</p>
              <h2 class="mt-1 text-2xl font-bold text-[#6b4f4f]">{shifts.length}</h2>
            </div>

            <div class="rounded-2xl bg-white p-5 shadow-md">
              <p class="text-sm text-[#9c7b7b]">Requests</p>
              <h2 class="mt-1 text-2xl font-bold text-[#6b4f4f]">{requests.length}</h2>
            </div>

            <div class="rounded-2xl bg-white p-5 shadow-md">
              <p class="text-sm text-[#9c7b7b]">Announcements</p>
              <h2 class="mt-1 text-2xl font-bold text-[#6b4f4f]">{announcements.length}</h2>
            </div>
          </section>

          <section class="rounded-3xl bg-white p-4 shadow-md md:p-6">
            <div class="mb-5 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p class="text-sm font-medium uppercase tracking-[0.18em] text-[#b28b93]">All team schedules</p>
                <h2 class="mt-1 text-2xl font-bold text-[#6b4f4f]">{calendarMonthLabel}</h2>
                <p class="mt-1 text-sm text-[#9c7b7b]">Every employee and admin shift by date</p>
              </div>

              <div class="flex gap-2">
                <button
                  type="button"
                  onclick={() => changeCalendarMonth(-1)}
                  class="rounded-lg bg-[#f7edee] px-4 py-2 text-sm font-semibold text-[#6b4f4f] hover:bg-[#f1e2e4]"
                >
                  Previous
                </button>
                <button
                  type="button"
                  onclick={() => (calendarMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1))}
                  class="rounded-lg bg-[#ff2d96] px-4 py-2 text-sm font-semibold text-white hover:opacity-90"
                >
                  Today
                </button>
                <button
                  type="button"
                  onclick={() => changeCalendarMonth(1)}
                  class="rounded-lg bg-[#f7edee] px-4 py-2 text-sm font-semibold text-[#6b4f4f] hover:bg-[#f1e2e4]"
                >
                  Next
                </button>
              </div>
            </div>

            {#if error}
              <div class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{error}</div>
            {:else if success}
              <div class="mb-4 rounded-lg bg-green-50 p-3 text-sm text-green-700">{success}</div>
            {/if}

            <div class="overflow-x-auto">
              <div class="min-w-245">
                <div class="grid grid-cols-7 gap-2 text-center">
                  {#each ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'] as dayName (dayName)}
                    <div class="rounded-lg bg-[#fff4f6] px-2 py-3 text-xs font-semibold uppercase tracking-[0.12em] text-[#9c7b7b]">
                      {dayName}
                    </div>
                  {/each}

                  {#each monthDays as day, index (`admin-calendar-day-${index}`)}
                    {#if day}
                      <div
                        class={`min-h-35 rounded-xl border p-2 text-left ${isToday(day) ? 'border-[#ff2d96] bg-[#fff4f8] ring-2 ring-[#ff2d96]/20' : 'border-[#ead8d8] bg-white'}`}
                      >
                        <div class="mb-2 flex items-center justify-between">
                          <span class={`text-sm font-bold ${isToday(day) ? 'text-[#ff2d96]' : 'text-[#6b4f4f]'}`}>
                            {day.getDate()}
                          </span>
                          <span class="text-[10px] text-[#b28b93]">{formatDate(day.toISOString()).split(',')[0]}</span>
                        </div>

                        <div class="space-y-1.5">
                          {#each shiftsForDay(day) as shift (shift.id ?? `${shift.employee_id}-${shift.start_time}`)}
                            <div
                              class="rounded-lg border-l-4 bg-[#fff0f6] px-2 py-1.5"
                              style={`border-left-color: ${shift.color || '#ff2d96'}`}
                            >
                              <p class="truncate text-[11px] font-bold text-[#6b4f4f]">
                                {getAssignedPersonName(shift.employee_id)}
                              </p>
                              <p class="truncate text-[10px] font-medium text-[#7d6161]">
                                {formatTime(shift.start_time)} - {formatTime(shift.end_time)}
                              </p>
                              <p class="truncate text-[10px] text-[#9c7b7b]">{shift.title || 'Scheduled shift'}</p>
                              <div class="mt-2 flex items-center gap-1">
                                <select
                                  aria-label="Move shift to another person"
                                  value={shift.employee_id ?? ''}
                                  onchange={(event) => handleShiftAssignmentChange(event, shift.id, day)}
                                  disabled={isPastDay(day)}
                                  class={`min-w-0 flex-1 rounded border border-[#efd9dd] bg-white px-1 py-0.5 text-[9px] text-[#6b4f4f] ${isPastDay(day) ? 'cursor-not-allowed opacity-50' : ''}`}
                                >
                                  {#each selectableEmployees as employee (employee.id)}
                                    <option value={employee.id}>
                                      {employee.full_name?.trim() || employee.email || 'Unnamed team member'}
                                    </option>
                                  {/each}
                                </select>
                                <button
                                  type="button"
                                  aria-label="Remove scheduled shift"
                                  onclick={() => removeShift(shift.id, day)}
                                  disabled={isPastDay(day)}
                                  class={`rounded border border-red-200 px-1.5 py-0.5 text-[9px] font-semibold text-red-600 hover:bg-red-50 ${isPastDay(day) ? 'cursor-not-allowed opacity-50 hover:bg-transparent' : ''}`}
                                >
                                  Remove
                                </button>
                              </div>
                            </div>
                          {/each}

                          {#if shiftsForDay(day).length === 0}
                            <p class="pt-2 text-[11px] text-[#c2a0a8]">No shifts</p>
                          {/if}
                        </div>
                      </div>
                    {:else}
                      <div class="min-h-35 rounded-xl bg-[#fffafc]"></div>
                    {/if}
                  {/each}
                </div>
              </div>
            </div>
          </section>

          <section class="grid gap-6 xl:grid-cols-2">
            <div class="rounded-3xl bg-white p-6 shadow-md">
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Create Shift</h2>

              <div class="space-y-4">
                <div>
                  <label for="admin-employee" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Employee</label>
                  <select id="admin-employee" bind:value={employee_id} class="w-full rounded-lg border p-3">
                    <option value="">Select an employee</option>
                    {#each selectableEmployees as employee (employee.id)}
                      <option value={employee.id}>
                        {employee.full_name?.trim() || employee.email || 'Unnamed team member'}
                        {employee.id === profile?.id ? ' (You)' : ''}
                      </option>
                    {/each}
                  </select>
                </div>

                <div>
                  <label for="admin-title" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Shift Title</label>
                  <input id="admin-title" bind:value={title} type="text" class="w-full rounded-lg border p-3" />
                </div>

                <div>
                  <label for="admin-role" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Role</label>
                  <input id="admin-role" bind:value={shift_role} type="text" class="w-full rounded-lg border p-3" />
                </div>

                <div class="grid gap-4 md:grid-cols-2">
                  <div>
                    <label for="admin-start" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Start Time</label>
                    <input id="admin-start" bind:value={start_time} type="datetime-local" class="w-full rounded-lg border p-3" />
                  </div>

                  <div>
                    <label for="admin-end" class="mb-2 block text-sm font-medium text-[#6b4f4f]">End Time</label>
                    <input id="admin-end" bind:value={end_time} type="datetime-local" class="w-full rounded-lg border p-3" />
                  </div>
                </div>

                <div>
                  <label for="admin-color" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Color</label>
                  <input id="admin-color" bind:value={color} type="color" class="h-12 w-full rounded-lg border p-2" />
                </div>

                <div>
                  <label for="admin-notes" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Notes</label>
                  <textarea id="admin-notes" bind:value={notes} class="min-h-25 w-full rounded-lg border p-3"></textarea>
                </div>

                <button
                  type="button"
                  onclick={createShift}
                  class="w-full rounded-lg bg-[#6b4f4f] py-3 text-white hover:opacity-90"
                >
                  Save Shift
                </button>
              </div>
            </div>

            <div class="rounded-3xl bg-white p-6 shadow-md">
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Post Announcement</h2>

              <div class="space-y-4">
                <div>
                  <label for="admin-announcement-title" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Title</label>
                  <input id="admin-announcement-title" bind:value={announcement_title} type="text" class="w-full rounded-lg border p-3" />
                </div>

                <div>
                  <label for="admin-announcement-message" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Message</label>
                  <textarea
                    id="admin-announcement-message"
                    bind:value={announcement_message}
                    class="min-h-35 w-full rounded-lg border p-3"
                  ></textarea>
                </div>

                <button
                  type="button"
                  onclick={createAnnouncement}
                  class="w-full rounded-lg bg-[#6b4f4f] py-3 text-white hover:opacity-90"
                >
                  Post Announcement
                </button>
              </div>
            </div>
          </section>

          <section class="grid gap-6 xl:grid-cols-2">
            <div class="rounded-3xl bg-white p-6 shadow-md">
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Time-Off Requests</h2>

              {#if requests.length === 0}
                <p class="text-[#9c7b7b]">No requests yet.</p>
              {:else}
                <div class="space-y-4">
                  {#each requests as request (request.id ?? request.employee_id ?? request.start_date ?? request.end_date ?? 'request')}
                    <div class="rounded-2xl border border-[#ead8d8] p-4">
                      <div class="mb-2 flex items-center justify-between gap-3">
                        <div>
                          <p class="font-semibold text-[#6b4f4f]">
                            {getAssignedPersonName(request.employee_id)}
                          </p>
                          <p class="text-sm text-[#9c7b7b]">
                            {formatDate(request.start_date)} - {formatDate(request.end_date)}
                          </p>
                        </div>

                        <span class={`rounded-full px-3 py-1 text-xs font-semibold ${statusClasses(request.status)}`}>
                          {request.status}
                        </span>
                      </div>

                      {#if request.reason}
                        <p class="mb-3 text-sm text-[#7d6161]">{request.reason}</p>
                      {/if}

                      {#if request.status === 'PENDING'}
                        <div class="flex gap-2">
                          <button
                            type="button"
                            onclick={() => updateRequestStatus(request.id, 'APPROVED')}
                            class="rounded-lg bg-green-600 px-4 py-2 text-white hover:opacity-90"
                          >
                            Approve
                          </button>

                          <button
                            type="button"
                            onclick={() => updateRequestStatus(request.id, 'DENIED')}
                            class="rounded-lg bg-red-600 px-4 py-2 text-white hover:opacity-90"
                          >
                            Deny
                          </button>
                        </div>
                      {/if}
                    </div>
                  {/each}
                </div>
              {/if}
            </div>

            <div class="rounded-3xl bg-white p-6 shadow-md">
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Announcements</h2>

              {#if announcements.length === 0}
                <p class="text-[#9c7b7b]">No announcements yet.</p>
              {:else}
                <div class="space-y-4">
                  {#each announcements as announcement (announcement.id ?? announcement.created_at ?? announcement.title ?? 'announcement')}
                    <div class="rounded-2xl border border-[#ead8d8] p-4">
                      <div class="flex items-start justify-between gap-3">
                        <div>
                          <h3 class="font-semibold text-[#6b4f4f]">{announcement.title}</h3>
                          <p class="mt-1 text-xs text-[#b28b93]">{formatDate(announcement.created_at)}</p>
                        </div>
                        <button
                          type="button"
                          onclick={() => deleteAnnouncement(announcement.id)}
                          class="rounded-lg bg-red-50 px-3 py-2 text-xs font-semibold text-red-600 hover:bg-red-100"
                        >
                          Delete
                        </button>
                      </div>
                      <p class="mt-3 text-sm leading-6 text-[#7d6161]">{announcement.message}</p>
                    </div>
                  {/each}
                </div>
              {/if}
            </div>

            <div class="rounded-3xl bg-white p-6 shadow-md">
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Recent Shifts</h2>

              {#if shifts.length === 0}
                <p class="text-[#9c7b7b]">No shifts created yet.</p>
              {:else}
                <div class="space-y-4">
                  {#each shifts as shift (shift.id ?? `${shift.title ?? 'shift'}-${shift.employee_id ?? 'employee'}-${shift.start_time ?? 'time'}`)}
                    <div
                      class="rounded-2xl border border-[#ead8d8] p-4"
                      style={`border-left: 6px solid ${shift.color || '#ff2d96'}`}
                    >
                      <p class="font-semibold text-[#6b4f4f]">{shift.title}</p>
                      <p class="text-sm text-[#9c7b7b]">{getAssignedPersonName(shift.employee_id)}</p>
                      <p class="text-sm text-[#7d6161]">
                        {formatDate(shift.start_time)} · {formatTime(shift.start_time)} - {formatTime(shift.end_time)}
                      </p>
                    </div>
                  {/each}
                </div>
              {/if}
            </div>
          </section>
        </div>
      {/if}
    </main>
  </div>
</div>