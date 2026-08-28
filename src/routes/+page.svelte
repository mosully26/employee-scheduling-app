<script lang="ts">
  import ScheduleShowcase from '$lib/components/ScheduleShowcase.svelte';

  const featureCards = [
    {
      title: 'Today’s Dashboard',
      description:
        'See your shift summary, upcoming workdays, reminders, and daily updates in one calm, organized view.',
      icon: '📊',
      accent: 'from-[#fff4f7] to-white',
      featured: true
    },
    {
      title: 'Schedule',
      description:
        'Check the week ahead, review upcoming shifts, and stay clear on who is working and when.',
      icon: '🗓️',
      accent: 'from-[#fff8f4] to-white'
    },
    {  
      title: 'Team Profiles',
      description:
        'Keep employee details, availability, and profile information easy to access and beautifully organized.',
      icon: '👤',
      accent: 'from-[#fdf5ff] to-white'
    },
  ];
</script>

<svelte:head>
  <title>Unique Beauty Scheduling Portal</title>
  <meta
    name="description"
    content="New Unique Beauty Organized Scheduling Application."
  />
</svelte:head>

<div class="relative min-h-screen overflow-hidden bg-[#fbf3f5] text-[#6f5255]">
  <div class="pointer-events-none absolute inset-0 overflow-hidden">
    <div class="absolute left-[-10rem] top-[-8rem] h-[28rem] w-[28rem] rounded-full bg-[#ffd6e5]/60 blur-3xl"></div>
    <div class="absolute right-[-8rem] top-[6rem] h-[26rem] w-[26rem] rounded-full bg-[#ffe8cf]/45 blur-3xl"></div>
    <div class="absolute bottom-[-10rem] left-[20%] h-[24rem] w-[24rem] rounded-full bg-[#f7d7df]/45 blur-3xl"></div>
    <div class="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.8),_transparent_38%)]"></div>
    <div class="absolute inset-0 opacity-[0.2] [background-image:linear-gradient(rgba(161,117,127,0.08)_1px,transparent_1px),linear-gradient(90deg,rgba(161,117,127,0.08)_1px,transparent_1px)] [background-size:42px_42px]"></div>
  </div>

  <div class="relative mx-auto max-w-7xl px-4 pb-16 pt-6 md:px-8 lg:px-10">
    <header class="mb-10 flex items-center justify-between rounded-full border border-white/60 bg-white/55 px-4 py-3 shadow-[0_10px_40px_rgba(164,120,129,0.10)] backdrop-blur md:px-6">
      <a href="/" class="flex items-center gap-3">
        <div class="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-sm ring-1 ring-[#efd5dc]">
          <img src="/favicon.png" alt="Unique Beauty logo" class="h-9 w-9 object-contain" />
        </div>

        <div>
          <p class="text-[1.6rem] font-semibold leading-none tracking-[0.01em] text-[#6d4d52]">
            Unique Beauty
          </p>
          <p class="mt-1 text-[0.72rem] uppercase tracking-[0.38em] text-[#b28b93]">
            Schedule
          </p>
        </div>
      </a>

      <div class="flex items-center gap-3">
        <a
          href="/signup"
          class="rounded-full border border-[#ead8dd] bg-white/85 px-6 py-3 text-sm font-semibold text-[#6f5255] shadow-sm backdrop-blur transition hover:-translate-y-0.5 hover:shadow-md"
        >
          Create Account
        </a>
        <a
          href="/login"
          class="rounded-full bg-gradient-to-r from-[#ff4f9d] to-[#ff7a7a] px-6 py-3 text-sm font-semibold text-white shadow-[0_14px_30px_rgba(255,97,157,0.32)] transition hover:-translate-y-0.5 hover:shadow-[0_18px_34px_rgba(255,97,157,0.40)]"
        >
          Login
        </a>
      </div>
    </header>

    <section class="grid items-start gap-12 lg:grid-cols-[0.95fr_1.05fr]">
      <div class="relative">

        <div class="relative max-w-3xl">
          <h1 class="relative text-5xl font-semibold leading-[0.92] tracking-[-0.04em] text-[#6d4d52] md:text-6xl xl:text-[5.4rem]">
            A More Personal Way
            <span class="mt-1 block bg-gradient-to-r from-[#ff3c97] via-[#ff6a9f] to-[#ff8b75] bg-clip-text text-transparent">
              To Manage The Week
            </span>
          </h1>
        </div>

        <p class="mt-7 max-w-2xl text-lg leading-8 text-[#85676d] md:text-[1.16rem]">
          Built for the Unique Beauty team, this portal keeps schedules, time-off requests,
          updates, and team details in one polished place so everyone stays organized without
          the extra back-and-forth.
        </p>

        <div class="mt-8 flex flex-wrap items-center gap-4">
          <a
            href="/schedule"
                        class="rounded-full bg-gradient-to-r from-[#ff4f9d] to-[#ff7d7a] px-7 py-4 text-sm font-semibold text-white shadow-[0_16px_32px_rgba(255,97,157,0.34)] transition hover:-translate-y-0.5"
          >
            View Schedule
          </a>
          <a
            href="/dashboard"
            class="rounded-full border border-[#ead8dd] bg-white/85 px-7 py-4 text-sm font-semibold text-[#6f5255] shadow-sm backdrop-blur transition hover:-translate-y-0.5 hover:shadow-md"
            >
            Dashboard
          </a>

          
        </div>

        <div class="mt-6 flex flex-wrap gap-3">
          <span class="rounded-full border border-[#ecdce0] bg-white/75 px-4 py-2 text-sm text-[#7c6066] shadow-sm">
           Reminders
          </span>
          <span class="rounded-full border border-[#ecdce0] bg-white/75 px-4 py-2 text-sm text-[#7c6066] shadow-sm">
            Weekly scheduling
          </span>
          <span class="rounded-full border border-[#ecdce0] bg-white/75 px-4 py-2 text-sm text-[#7c6066] shadow-sm">
            Shift Changes
          </span>
        </div>

        <div class="mt-10 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {#each featureCards as card}
            <div
              class={`group rounded-[2rem] border border-white/70 bg-gradient-to-br ${card.accent} p-5 shadow-[0_15px_40px_rgba(163,122,131,0.10)] transition duration-300 hover:-translate-y-1 hover:shadow-[0_22px_50px_rgba(163,122,131,0.14)] ${card.featured ? 'xl:-translate-y-3' : ''} ${card.wide ? 'md:col-span-2 xl:col-span-1' : ''}`}
            >
              <div class="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-white shadow-sm ring-1 ring-[#f0dde2] text-xl">
                {card.icon}
              </div>

              <div class="space-y-2">
                <h3 class="text-[1.35rem] font-semibold tracking-[-0.02em] text-[#6e5055]">
                  {card.title}
                </h3>
                <p class="text-[0.98rem] leading-7 text-[#8b6d73]">
                  {card.description}
                </p>
              </div>
            </div>
          {/each}
        </div>
      </div>

      <div class="relative">
        <ScheduleShowcase />
      </div>
    </section>
  </div>
</div>