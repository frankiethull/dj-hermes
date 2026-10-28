export default {
  id: 'dj-hermes',
  name: 'dj-hermes',
  defaultEnabled: false,
  register(ctx) {
    // Command palette command: drop a beat
    ctx.register({
      id: 'dj-hermes/drop-beat',
      area: 'PALETTE_AREA',
      data: {
        label: 'DJ Hermes: Drop a Beat',
        command: 'dj-hermes: <beat description>',
      },
      render: () => null,
    });

    // Pane for beat editing / preview
    ctx.register({
      id: 'dj-hermes/beat-pane',
      area: 'panes',
      data: {
        title: 'DJ Hermes',
        placement: 'bottom',
        height: '250px',
      },
      render: ({ jsx }) => {
        return jsx('div', {
          style: { padding: '16px', fontFamily: 'system-ui' },
          children: [
            jsx('h3', { children: 'DJ Hermes • Beat Studio' }),
            jsx('p', { children: 'Prompt Rhythmancer → Render with maelstrom → Export to Strudel' }),
            jsx('div', {
              style: { marginTop: '8px', display: 'flex', gap: '8px' },
              children: [
                jsx('button', { children: 'Generate' }),
                jsx('button', { children: 'Render' }),
                jsx('button', { children: 'Export' }),
              ],
            }),
          ],
        });
      },
    });

    // Sidebar nav entry
    ctx.register({
      id: 'dj-hermes/nav',
      area: 'SIDEBAR_NAV_AREA',
      data: { path: '/dj-hermes', label: 'DJ Hermes', codicon: 'pulse' },
    });
  },
};
