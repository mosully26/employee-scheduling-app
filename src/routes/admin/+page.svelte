<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';

  let profile = $state<any>(null);
  let employees = $state<any[]>([]);
  let shifts = $state<any[]>([]);
  let requests = $state<any[]>([]);
  let announcements = $state<any[]>([]);

  let loading = $state(true);
  let error = $state('');
  let success = $state('');
  let sidebarOpen = $state(false);

  let employee_id = $state('');
  let title = $state('');
  let shift_role = $state('');
  let start_time = $state('');
  let end_time = $state('');
  let color = $state('#ff2d96');
  let notes = $state('');

  let announcement_title = $state('');
  let announcement_message = $state('');

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

    profile = profileData;
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
      .order('start_time', { ascending: true })
      .limit(10);

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

      const { error: insertError } = await supabase.from('shifts').insert([
        {
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
    } catch (err) {
      console.error(err);
      error = 'Something went wrong creating the shift.';
    }
  }

  async function updateRequestStatus(id: string, status: 'APPROVED' | 'DENIED') {
    error = '';
    success = '';

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

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString([], {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  }

  function formatTime(date: string) {
    return new Date(date).toLocaleTimeString([], {
      hour: 'numeric',
      minute: '2-digit'
    });
  }

  function statusClasses(status: string) {
    if (status === 'APPROVED') return 'bg-green-100 text-green-700';
    if (status === 'DENIED') return 'bg-red-100 text-red-700';
    return 'bg-yellow-100 text-yellow-700';
  }

  function getEmployeeName(id: string) {
    return employees.find((employee) => employee.id === id)?.full_name ?? 'Employee';
  }
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

          <section class="grid gap-6 xl:grid-cols-2">
            <div class="rounded-3xl bg-white p-6 shadow-md">
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Create Shift</h2>

              <div class="space-y-4">
                <div>
                  <label for="admin-employee" class="mb-2 block text-sm font-medium text-[#6b4f4f]">Employee</label>
                  <select id="admin-employee" bind:value={employee_id} class="w-full rounded-lg border p-3">
                    <option value="">Select an employee</option>
                    {#each employees as employee}
                      <option value={employee.id}>{employee.full_name}</option>
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
                  <textarea id="admin-notes" bind:value={notes} class="min-h-[100px] w-full rounded-lg border p-3"></textarea>
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
                    class="min-h-[140px] w-full rounded-lg border p-3"
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
                  {#each requests as request}
                    <div class="rounded-2xl border border-[#ead8d8] p-4">
                      <div class="mb-2 flex items-center justify-between gap-3">
                        <div>
                          <p class="font-semibold text-[#6b4f4f]">
                            {getEmployeeName(request.employee_id)}
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
              <h2 class="mb-4 text-2xl font-bold text-[#6b4f4f]">Recent Shifts</h2>

              {#if shifts.length === 0}
                <p class="text-[#9c7b7b]">No shifts created yet.</p>
              {:else}
                <div class="space-y-4">
                  {#each shifts as shift}
                    <div
                      class="rounded-2xl border border-[#ead8d8] p-4"
                      style={`border-left: 6px solid ${shift.color || '#ff2d96'}`}
                    >
                      <p class="font-semibold text-[#6b4f4f]">{shift.title}</p>
                      <p class="text-sm text-[#9c7b7b]">{getEmployeeName(shift.employee_id)}</p>
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