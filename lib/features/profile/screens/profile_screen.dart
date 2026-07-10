import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_cupertino_theme.dart';
import '../../../shared/widgets/app_header_controls.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/app_silver_box.dart';
import '../../../shared/widgets/app_top_toast.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../universities/widgets/nqaae_ui.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const double _horizontalPadding = 18;

  final _searchController = TextEditingController();
  final _imagePicker = ImagePicker();
  late _ProfileDraft _savedDraft;
  late _ProfileDraft _draft;
  final _controllers = <String, TextEditingController>{};
  String? _editingField;
  ImageProvider? _avatarImage;
  ImageProvider? _savedAvatarImage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _savedDraft = _ProfileDraft();
    _draft = _savedDraft.copy();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  void _startEditing(String field) {
    final controller = _controllers.putIfAbsent(
      field,
      () => TextEditingController(),
    );
    controller.text = _draft.valueFor(field);
    setState(() => _editingField = field);
  }

  void _commitField(String field) {
    final value = _controllers[field]?.text.trim();
    if (value != null && value.isNotEmpty) {
      _draft.update(field, value);
    }
    if (_editingField == field) {
      setState(() => _editingField = null);
    }
  }

  void _handleFieldChanged(String field, String value) {
    _draft.update(field, value);
    _recalculateDirtyState();
  }

  void _recalculateDirtyState() {
    final nextValue =
        !_draft.matches(_savedDraft) || _avatarImage != _savedAvatarImage;
    if (nextValue != _hasChanges) {
      setState(() => _hasChanges = nextValue);
    }
  }

  void _saveChanges() {
    if (_editingField != null) {
      _commitField(_editingField!);
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _savedDraft = _draft.copy();
      _savedAvatarImage = _avatarImage;
      _hasChanges = false;
    });
    showAppTopToast(context, message: 'Changes saved');
  }

  Future<void> _choosePhoto() async {
    final source = Theme.of(context).platform == TargetPlatform.iOS
        ? await _showCupertinoPhotoSheet()
        : await _showMaterialPhotoSheet();
    if (source == null) return;

    final photo = await _imagePicker.pickImage(source: source);
    if (!mounted || photo == null) return;
    setState(() => _avatarImage = FileImage(File(photo.path)));
    _recalculateDirtyState();
  }

  Future<ImageSource?> _showCupertinoPhotoSheet() {
    return showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) => AppCupertinoTheme(
        child: CupertinoActionSheet(
          title: Text(
            'Profile photo',
            style: AppCupertinoTheme.titleTextStyle(),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: Text(
                'Take Photo',
                style: AppCupertinoTheme.actionTextStyle(),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Text(
                'Choose from Library',
                style: AppCupertinoTheme.actionTextStyle(),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppCupertinoTheme.cancelTextStyle()),
          ),
        ),
      ),
    );
  }

  Future<ImageSource?> _showMaterialPhotoSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Library'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              title: const Center(
                child: Text('Cancel', style: TextStyle(color: AppColors.error)),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NqaaeBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            AppScreenHeader(
              horizontalPadding: _horizontalPadding,
              shadowKey: const ValueKey('profile-header-shadow'),
              center: AppHeaderControls(
                backKey: const ValueKey('profile-header-back'),
                searchShellKey: const ValueKey('profile-search-shell'),
                notificationsKey: const ValueKey(
                  'profile-header-notifications',
                ),
                searchController: _searchController,
                onSearchChanged: (_) {},
                onVoiceSearch: () {},
                onBack: _handleBack,
              ),
            ),
            AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 34,
              child: Text(
                'PROFILE',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 24,
              child: Center(
                child: ProfileAvatar(
                  size: 126,
                  showCameraButton: true,
                  image: _avatarImage,
                  onCameraPressed: _choosePhoto,
                ),
              ),
            ),
            AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 28,
              child: _ProfileInfoCard(
                draft: _draft,
                editingField: _editingField,
                controllers: _controllers,
                onEdit: _startEditing,
                onChanged: _handleFieldChanged,
                onSubmitted: _commitField,
              ),
            ),
            if (_hasChanges)
              AppSliverBox(
                left: _horizontalPadding,
                right: _horizontalPadding,
                top: 22,
                bottom: 42,
                child: _SaveChangesButton(onPressed: _saveChanges),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDraft {
  String fullName = 'Your Name';
  String phoneNumber = '+998 90 327 97 87';
  String email = 'youremail@email.com';
  String username = 'yourname';

  _ProfileDraft copy() => _ProfileDraft()
    ..fullName = fullName
    ..phoneNumber = phoneNumber
    ..email = email
    ..username = username;

  bool matches(_ProfileDraft other) =>
      fullName == other.fullName &&
      phoneNumber == other.phoneNumber &&
      email == other.email &&
      username == other.username;

  String valueFor(String field) => switch (field) {
    'full-name' => fullName,
    'phone-number' => phoneNumber,
    'email' => email,
    'username' => username,
    _ => '',
  };

  void update(String field, String value) {
    switch (field) {
      case 'full-name':
        fullName = value;
      case 'phone-number':
        phoneNumber = value;
      case 'email':
        email = value;
      case 'username':
        username = value.replaceFirst(RegExp(r'^@'), '');
    }
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.draft,
    required this.editingField,
    required this.controllers,
    required this.onEdit,
    required this.onChanged,
    required this.onSubmitted,
  });

  final _ProfileDraft draft;
  final String? editingField;
  final Map<String, TextEditingController> controllers;
  final ValueChanged<String> onEdit;
  final void Function(String field, String value) onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => GlassCard(
    borderRadius: const BorderRadius.all(Radius.circular(24)),
    padding: EdgeInsets.zero,
    blurStrength: 14,
    borderWidth: 1,
    backgroundColor: Colors.white.withValues(alpha: 0.045),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProfileInfoRow(
          label: 'Full name',
          field: 'full-name',
          value: draft.fullName,
          editingField: editingField,
          controllers: controllers,
          onEdit: onEdit,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        _ProfileInfoRow(
          label: 'Phone number',
          field: 'phone-number',
          value: draft.phoneNumber,
          editingField: editingField,
          controllers: controllers,
          onEdit: onEdit,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        _ProfileInfoRow(
          label: 'Email',
          field: 'email',
          value: draft.email,
          editingField: editingField,
          controllers: controllers,
          onEdit: onEdit,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        _ProfileInfoRow(
          label: 'Username',
          field: 'username',
          value: '@${draft.username}',
          editingField: editingField,
          controllers: controllers,
          onEdit: onEdit,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          isLast: true,
        ),
      ],
    ),
  );
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.field,
    required this.value,
    required this.editingField,
    required this.controllers,
    required this.onEdit,
    required this.onChanged,
    required this.onSubmitted,
    this.isLast = false,
  });
  final String label, field, value;
  final String? editingField;
  final Map<String, TextEditingController> controllers;
  final ValueChanged<String> onEdit, onSubmitted;
  final void Function(String field, String value) onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isEditing = editingField == field;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.055),
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.openSans(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 6,
            child: isEditing
                ? TextField(
                    key: ValueKey('profile-editor-$field'),
                    controller: controllers[field],
                    autofocus: true,
                    textAlign: TextAlign.right,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) => onChanged(field, value),
                    onSubmitted: (_) => onSubmitted(field),
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  )
                : InkWell(
                    key: ValueKey('profile-value-$field'),
                    onTap: () => onEdit(field),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.openSans(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SaveChangesButton extends StatelessWidget {
  const _SaveChangesButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradient(style: GradientStyle.linear),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(27),
          child: InkWell(
            key: const ValueKey('profile-save-button'),
            borderRadius: BorderRadius.circular(27),
            onTap: onPressed,
            child: Center(
              child: Text(
                'Save Changes',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
