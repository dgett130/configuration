module.exports = {
  preset: 'angular',
  releaseCount: 0,
  writerOpts: {
    headerPartial: '## 🎉 Project v{{version}}\n\n_Release date: {{date}}_\n',
    transform: (commit, context) => {
      const typeMap = {
        feat: '✨ Features',
        chore: '🔧 Chores',
      };
      const newType = typeMap[commit.type];
      if (!newType) return;
      commit.type = newType;
      return commit;
    },
    groupBy: 'type',
    commitGroupsSort: (a, b) => {
      const order = ['✨ Features', '🔧 Chores'];
      return order.indexOf(a.title) - order.indexOf(b.title);
    },
  },
};
