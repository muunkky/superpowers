const assert = require('assert');
const {
  browserLauncherForPlatform,
  parseLauncherCommand
} = require('../../skills/brainstorming/scripts/server.cjs');

let passed = 0;
let failed = 0;

async function test(name, fn) {
  try {
    await fn();
    console.log(`  PASS: ${name}`);
    passed++;
  } catch (e) {
    console.log(`  FAIL: ${name}`);
    console.log(`    ${e.message}`);
    failed++;
  }
}

(async () => {
  console.log('\n--- Browser Launcher ---');

  await test('Windows launcher does not route URLs through cmd.exe', () => {
    const url = 'http://localhost:54122/?key=abc&x=SAFE&echo=INJECTED';
    const launcher = browserLauncherForPlatform(url, {
      platform: 'win32',
      osRelease: '10.0.26200',
      env: {}
    });

    assert.deepStrictEqual(launcher, {
      bin: 'rundll32.exe',
      args: ['url.dll,FileProtocolHandler', url]
    });
    assert(!launcher.args.includes('/c'), 'Windows launcher must not pass /c to a command interpreter');
  });

  await test('WSL launcher does not route URLs through cmd.exe', () => {
    const url = 'http://localhost:54122/?key=abc&x=SAFE&echo=INJECTED';
    const launcher = browserLauncherForPlatform(url, {
      platform: 'linux',
      osRelease: '5.15.167.4-microsoft-standard-WSL2',
      env: {}
    });

    assert.deepStrictEqual(launcher, {
      bin: 'rundll32.exe',
      args: ['url.dll,FileProtocolHandler', url]
    });
  });

  await test('Linux launcher stays headless without a display', () => {
    assert.strictEqual(
      browserLauncherForPlatform('http://localhost:1/', {
        platform: 'linux',
        osRelease: '6.0.0',
        env: {}
      }),
      null
    );
  });

  console.log('\n--- parseLauncherCommand (operator launcher tokenizer) ---');

  await test('metacharacters survive as inert literal tokens (no shell)', () => {
    // These tokens are handed to execFile, which spawns no shell, so ';' etc.
    // are ordinary argv elements — never operators. The tokenizer must not give
    // them any special meaning.
    assert.deepStrictEqual(
      parseLauncherCommand('open ; touch pwned'),
      ['open', ';', 'touch', 'pwned']
    );
    assert.deepStrictEqual(
      parseLauncherCommand('open $(evil)'),
      ['open', '$(evil)']
    );
    assert.deepStrictEqual(
      parseLauncherCommand('open `evil`'),
      ['open', '`evil`']
    );
    assert.deepStrictEqual(
      parseLauncherCommand('open && evil'),
      ['open', '&&', 'evil']
    );
    assert.deepStrictEqual(
      parseLauncherCommand('open | evil'),
      ['open', '|', 'evil']
    );
  });

  await test('quoted spaced path stays one argument (double quotes stripped)', () => {
    assert.deepStrictEqual(
      parseLauncherCommand('bin "/A/My Browser.app/x"'),
      ['bin', '/A/My Browser.app/x']
    );
  });

  await test('single-quoted spaced span stays one argument (quotes stripped)', () => {
    assert.deepStrictEqual(
      parseLauncherCommand("bin '/A/My Browser.app/x'"),
      ['bin', '/A/My Browser.app/x']
    );
  });

  await test('lifecycle shape strips double quotes', () => {
    assert.deepStrictEqual(
      parseLauncherCommand('node "/x/s.cjs" "/y/m"'),
      ['node', '/x/s.cjs', '/y/m']
    );
  });

  await test('JSON-quoted round-trip: a spaced path embedded via JSON.stringify tokenizes back to one arg', () => {
    // Mirrors the call-site pattern (BRAINSTORM_OPEN_CMD + ' ' + JSON.stringify(arg)):
    // a double-quoted JSON path with spaces must come back out as exactly one argv element.
    const spacedPath = '/Applications/My Browser.app/Contents/MacOS/My Browser';
    const cmd = 'open ' + JSON.stringify(spacedPath);
    assert.deepStrictEqual(parseLauncherCommand(cmd), ['open', spacedPath]);
  });

  await test('empty input -> []', () => {
    assert.deepStrictEqual(parseLauncherCommand(''), []);
  });

  await test('whitespace-only input -> []', () => {
    assert.deepStrictEqual(parseLauncherCommand('   '), []);
    assert.deepStrictEqual(parseLauncherCommand('\t \n'), []);
  });

  await test('quoted-empty input -> [\'\'] (one empty argv element)', () => {
    assert.deepStrictEqual(parseLauncherCommand('""'), ['']);
    assert.deepStrictEqual(parseLauncherCommand("''"), ['']);
  });

  await test('unmatched quote flushes the open span and never throws', () => {
    assert.deepStrictEqual(parseLauncherCommand("open 'foo"), ['open', 'foo']);
    assert.deepStrictEqual(parseLauncherCommand('open "foo'), ['open', 'foo']);
  });

  console.log(`\n--- Results: ${passed} passed, ${failed} failed ---`);
  if (failed > 0) process.exit(1);
})();
