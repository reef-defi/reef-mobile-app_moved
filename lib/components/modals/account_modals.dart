import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/ensureVisibleWhenFocused.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountImportContent extends StatefulWidget {
  final VoidCallback next;
  final Function(StoredAccount) callback;

  const AccountImportContent(
      {Key? key, required this.next, required this.callback})
      : super(key: key);

  @override
  State<AccountImportContent> createState() => _AccountImportContentState();
}

class _AccountImportContentState extends State<AccountImportContent> {
  final TextEditingController _mnemonicController = TextEditingController();
  late String mnemonic = "";
  StoredAccount? account;
  bool errorMnemonic = false;
  bool errorDuplicated = false;

  @override
  void initState() {
    super.initState();
    _mnemonicController.addListener(() {
      if (mnemonic == _mnemonicController.text) return;
      setState(() {
        mnemonic = _mnemonicController.text;
        validateSeed();
      });
    });
  }

  @override
  void dispose() {
    _mnemonicController.dispose();
    super.dispose();
  }

  validateSeed() async {
    if (mnemonic.isEmpty) {
      setState(() {
        errorDuplicated = false;
        errorMnemonic = false;
        account = null;
      });
      return;
    }

    if (mnemonic.split(" ").length != 12 && mnemonic.split(" ").length != 24) {
      setState(() {
        errorDuplicated = false;
        errorMnemonic = true;
        account = null;
      });
      return;
    }

    bool validMnemonic =
        await ReefAppState.instance.accountCtrl.checkMnemonicValid(mnemonic);
    if (!validMnemonic) {
      setState(() {
        errorDuplicated = false;
        errorMnemonic = true;
        account = null;
      });
      return;
    }

    var response =
        await ReefAppState.instance.accountCtrl.accountFromMnemonic(mnemonic);
    var importedAccount = StoredAccount.fromString(response);
    var stored = await ReefAppState.instance.accountCtrl
        .getStorageAccount(importedAccount.address);
    if (stored != null) {
      errorDuplicated = true;
      setState(() {
        errorDuplicated = true;
        errorMnemonic = false;
        account = null;
      });
    } else {
      setState(() {
        errorDuplicated = false;
        errorMnemonic = false;
        account = importedAccount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 24, bottom: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (account != null) ...[
            buildAccountBox(account),
            const Gap(12),
          ],
          Builder(builder: (context) {
            return Text(
              AppLocalizations.of(context)!.existing_seed,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Styles.textLightColor),
            );
          }),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Styles.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorMnemonic || errorDuplicated
                    ? Styles.errorColor
                    : const Color(0x20000000),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _mnemonicController,
              maxLines: 3,
              decoration: const InputDecoration.collapsed(hintText: ''),
              style: TextStyle(
                color: errorMnemonic || errorDuplicated
                    ? Styles.errorColor
                    : Styles.textColor,
              ),
            ),
          ),
          if (errorMnemonic || errorDuplicated) ...[
            const Gap(8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Styles.errorColor,
                  size: 16,
                ),
                const Gap(8),
                Flexible(
                  child: Text(
                    errorDuplicated
                        ? AppLocalizations.of(context)!.account_already_added
                        : AppLocalizations.of(context)!.invalid_mnemonic_seed,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          const Gap(24),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    splashFactory: account == null
                        ? NoSplash.splashFactory
                        : InkSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 5,
                    backgroundColor: account == null
                        ? const Color(0xff9d6cff)
                        : Styles.secondaryAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (account != null) {
                      widget.callback(account!);
                      widget.next();
                    }
                  },
                  child: Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.next_step,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(Icons.arrow_forward,
                      color: Styles.whiteColor, size: 20),
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
}

class AccountCreationContent extends StatefulWidget {
  final VoidCallback next;
  final StoredAccount? account;

  const AccountCreationContent(
      {Key? key, required this.next, required this.account})
      : super(key: key);

  @override
  State<AccountCreationContent> createState() => _AccountCreationContentState();
}

class _AccountCreationContentState extends State<AccountCreationContent> {
  bool _checkedValue = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 24, bottom: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAccountBox(widget.account),
          const Gap(12),
          Builder(builder: (context) {
            return Text(
              AppLocalizations.of(context)!.generated_2_word,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Styles.textLightColor),
            );
          }),
          const Gap(8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Styles.whiteColor,
              border: Border.all(
                color: const Color(0x20000000),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 24,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.account?.mnemonic ??
                    AppLocalizations.of(context)!.loading + "...",
                style: TextStyle(color: Styles.primaryAccentColorDark),
              ),
            ),
          ),
          const Gap(4),
          TextButton(
              style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () {
                if (widget.account?.mnemonic != null) {
                  Clipboard.setData(
                      ClipboardData(text: widget.account?.mnemonic));
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copy,
                    size: 12,
                    color: Styles.textLightColor,
                  ),
                  const Gap(2),
                  Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.copy_to_clipboard,
                      style: TextStyle(color: Styles.textColor, fontSize: 12),
                    );
                  }),
                ],
              )),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: Styles.primaryAccentColorDark,
                size: 16,
              ),
              const Gap(8),
              Flexible(
                child: Builder(builder: (context) {
                  return Text(
                    AppLocalizations.of(context)!.please_write_down,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  );
                }),
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              Checkbox(
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: MaterialStateProperty.all<Color>(Colors.grey[800]!),
                value: _checkedValue,
                onChanged: (bool? value) {
                  setState(() {
                    _checkedValue = value ?? false;
                  });
                },
              ),
              const Gap(8),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.i_saved_mnemonic,
                  style: TextStyle(color: Colors.grey[600]!, fontSize: 14),
                ),
              )
            ],
          ),
          const Gap(16),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    splashFactory:
                        (!_checkedValue || widget.account?.mnemonic == null)
                            ? NoSplash.splashFactory
                            : InkSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 5,
                    backgroundColor:
                        (!_checkedValue || widget.account?.mnemonic == null)
                            ? const Color(0xff9d6cff)
                            : Styles.secondaryAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_checkedValue && widget.account?.mnemonic != null)
                      widget.next();
                  },
                  child: Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.next_step,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(Icons.arrow_forward,
                      color: Styles.whiteColor, size: 20),
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
}

class AccountCreationConfirmContent extends StatefulWidget {
  final VoidCallback prev;
  final StoredAccount? account;
  final Future<dynamic> Function(StoredAccount) saveAccount;
  final bool fromMnemonic;

  const AccountCreationConfirmContent(
      {Key? key,
      required this.prev,
      required this.account,
      required this.saveAccount,
      required this.fromMnemonic})
      : super(key: key);

  @override
  State<AccountCreationConfirmContent> createState() =>
      _AccountCreationConfirmContentState();
}

class _AccountCreationConfirmContentState
    extends State<AccountCreationConfirmContent> {
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodePassword = FocusNode();
  FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late String name;
  String password = "";
  String confirmPassword = "";
  bool _hasPassword = false;
  bool _hasBioAuth = false;
  bool _biometricsIsAvailable = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.account != null) {
        if (widget.account?.name.isEmpty as bool) {
          name = "<No Name>";
        } else {
          name = widget.account?.name as String;
        }
      } else {
        name = "<No Name>";
      }
    });
    _nameController.text = name == "<No Name>" ? "" : name;
    _nameController.addListener(() {
      setState(() {
        name = _nameController.text;
        widget.account?.name = name;
      });
    });
    _passwordController.addListener(() {
      if (password == _passwordController.text) return;
      setState(() {
        password = _passwordController.text;
        _passwordError = password.length < 6;
      });
    });
    _confirmPasswordController.addListener(() {
      if (confirmPassword == _confirmPasswordController.text) return;
      setState(() {
        confirmPassword = _confirmPasswordController.text;
        _confirmPasswordError = password != confirmPassword;
      });
    });
    ReefAppState.instance.storageCtrl
        .getValue(StorageKey.password.name)
        .then((value) => setState(() {
              _hasPassword = value != null && value.isNotEmpty;
            }));
    ReefAppState.instance.signingCtrl
        .checkBiometricsSupport()
        .then((value) => setState(() {
              _biometricsIsAvailable = value;
            }));
    setState(() {
      _hasBioAuth =
          ReefAppState.instance.model.appConfig.isBiometricAuthEnabled;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusedCtx = FocusManager.instance.primaryFocus!.context;

    Future.delayed(const Duration(milliseconds: 400))
        .then((_) => Scrollable.ensureVisible(
              focusedCtx!,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutQuad,
            ));
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 24, bottom: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAccountBox(widget.account, name: name),
          const Gap(12),
          Text(
            AppLocalizations.of(context)!.descriptive_account_name,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Styles.textLightColor),
          ),
          const Gap(8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                focusNode: _focusNodeName,
                controller: _nameController,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(
                  fontSize: 16,
                ),
              )),
          const Gap(16),
          if (!_hasPassword || _hasBioAuth) ...[
            Row(
              children: [
                if (_biometricsIsAvailable)
                  Checkbox(
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    fillColor:
                        MaterialStateProperty.all<Color>(Colors.grey[800]!),
                    value: _hasBioAuth,
                    onChanged: (bool? value) {
                      setState(() {
                        _hasBioAuth = value ?? false;
                      });
                      ReefAppState.instance.appConfigCtrl
                          .setBiometricAuth(value == true);
                    },
                  ),
                const Gap(8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!
                        .enable_biometric_authentication,
                    style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
                  ),
                )
              ],
            ),
            if (_biometricsIsAvailable) const Gap(16),
            if (!_hasBioAuth)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.password_for_reef_app,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Styles.textLightColor),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Styles.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _passwordError
                            ? Styles.errorColor
                            : const Color(0x20000000),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      focusNode: _focusNodePassword,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration.collapsed(hintText: ''),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            if (_passwordError) ...[
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Styles.errorColor,
                    size: 16,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.password_too_short,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
            if (password.isNotEmpty && !_passwordError) ...[
              const Gap(16),
              Text(
                AppLocalizations.of(context)!.repetitive_password,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Styles.textLightColor),
              ),
              const Gap(8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Styles.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _confirmPasswordError
                        ? Styles.errorColor
                        : const Color(0x20000000),
                    width: 1,
                  ),
                ),
                child: TextField(
                  focusNode: _focusNodeConfirmPassword,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              if (_confirmPasswordError) ...[
                const Gap(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      color: Styles.errorColor,
                      size: 16,
                    ),
                    const Gap(8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.password_do_not_match,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ]
          ],
          const Gap(24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            width: double.infinity,
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      widget.prev();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black12,
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Styles.textColor,
                      size: 20,
                    )),
                const Gap(4),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: !(name.trim().isNotEmpty &&
                              (!_hasPassword || password.isNotEmpty))
                          ? NoSplash.splashFactory
                          : InkSplash.splashFactory,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      shadowColor: const Color(0x559d6cff),
                      elevation: 5,
                      backgroundColor: (name.isNotEmpty &&
                              (_hasPassword ||
                                  (password.isNotEmpty &&
                                      !_passwordError &&
                                      !_confirmPasswordError)))
                          ? Styles.secondaryAccentColor
                          : const Color(0xff9d6cff),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: (name.trim().isNotEmpty &&
                            name.trim() != "<No Name>" &&
                            (_hasPassword ||
                                (password.isNotEmpty &&
                                    !_passwordError &&
                                    !_confirmPasswordError &&
                                    _confirmPasswordController.text ==
                                        _passwordController.text) ||
                                _hasBioAuth))
                        ? () {
                            if (widget.account != null) {
                              widget
                                  .saveAccount(widget.account as StoredAccount);
                              if (!_hasPassword && password.isNotEmpty) {
                                ReefAppState.instance.storageCtrl.setValue(
                                    StorageKey.password.name, password);
                              }

                              Navigator.of(context).pop();

                              if (!widget.fromMnemonic) {
                                ReefAccount signer = ReefAccount(
                                  address: widget.account!.address,
                                  name: name,
                                  balance: BigInt.zero,
                                  evmAddress: "",
                                  isEvmClaimed: false,
                                  iconSVG: widget.account!.svg,
                                );
                                showBindEvmModal(context, bindFor: signer);
                              }
                            }
                          }
                        : null,
                    child: Text(
                      widget.fromMnemonic
                          ? AppLocalizations.of(context)!.import_the_account
                          : AppLocalizations.of(context)!.add_the_account,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentScreen extends StatefulWidget {
  CurrentScreen({Key? key, required this.fromMnemonic}) : super(key: key);

  final bool fromMnemonic;
  final ReefAppState reefState = ReefAppState.instance;
  final StorageService storageService = ReefAppState.instance.storage;

  @override
  State<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  int activeIndex = 0;
  StoredAccount? account;

  void generateAccount() async {
    var response = await widget.reefState.accountCtrl.generateAccount();
    var generatedAccount = StoredAccount.fromString(response);
    setState(() {
      account = generatedAccount;
    });
  }

  void importAccount(StoredAccount importedAccount) {
    setState(() {
      account = importedAccount;
    });
  }

  Future saveAccount(StoredAccount account) async {
    await ReefAppState.instance.accountCtrl.saveAccount(account);
  }

  nextIndex() {
    setState(() {
      activeIndex = 1;
    });
  }

  prevIndex() {
    setState(() {
      activeIndex = 0;
    });
  }

  List<Widget> content = [];

  @override
  void initState() {
    super.initState();
    if (!widget.fromMnemonic) {
      generateAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: activeIndex == 0
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeInOutQuad,
      secondCurve: Curves.easeInOutQuad,
      sizeCurve: Curves.easeInOutQuad,
      firstChild: widget.fromMnemonic
          ? AccountImportContent(next: nextIndex, callback: importAccount)
          : AccountCreationContent(next: nextIndex, account: account),
      secondChild: AccountCreationConfirmContent(
          prev: prevIndex,
          account: account,
          saveAccount: saveAccount,
          fromMnemonic: widget.fromMnemonic),
    );
  }
}

Widget buildAccountBox(StoredAccount? account, {name = "<No Name>"}) {
  return ViewBoxContainer(
      color: Styles.whiteColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black12,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(64),
                  child: (account?.svg != null)
                      ? SvgPicture.string(account?.svg as String)
                      : Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: Colors.grey[600]!),
                        )),
            ),
            const Gap(12),
            Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(2),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Text(
                      "Address: ${account?.address.shorten() ?? "Loading..."}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]!),
                    ),
                    const Gap(2),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.copy, size: 12),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: account?.address));
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ));
}

void showCreateAccountModal(BuildContext context,
    {bool fromMnemonic = false, bool fromJson = false}) {
  showModal(context,
      headText: fromMnemonic
          ? AppLocalizations.of(context)!.import_the_account
          : AppLocalizations.of(context)!.create_new_account,
      dismissible: true,
      child: CurrentScreen(fromMnemonic: fromMnemonic));
}
