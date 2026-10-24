// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Invoice {
  String get id => throw _privateConstructorUsedError;
  int get invoiceNumber => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  String get discountType =>
      throw _privateConstructorUsedError; // 'FLAT' or 'PERCENTAGE'
  double get taxAmount => throw _privateConstructorUsedError;
  String get taxType => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  double get paidAmount => throw _privateConstructorUsedError;
  double get balanceAmount => throw _privateConstructorUsedError;
  String get paymentStatus =>
      throw _privateConstructorUsedError; // 'PAID', 'PARTIAL', 'UNPAID'
  String get status => throw _privateConstructorUsedError; // 'ACTIVE', 'VOID'
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError; // Relationships
  List<InvoiceItem> get items => throw _privateConstructorUsedError;
  List<Payment> get payments => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InvoiceCopyWith<Invoice> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceCopyWith<$Res> {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) then) =
      _$InvoiceCopyWithImpl<$Res, Invoice>;
  @useResult
  $Res call(
      {String id,
      int invoiceNumber,
      String? customerId,
      double subtotal,
      double discountAmount,
      String discountType,
      double taxAmount,
      String taxType,
      double total,
      double paidAmount,
      double balanceAmount,
      String paymentStatus,
      String status,
      String? note,
      DateTime createdAt,
      DateTime updatedAt,
      List<InvoiceItem> items,
      List<Payment> payments});
}

/// @nodoc
class _$InvoiceCopyWithImpl<$Res, $Val extends Invoice>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNumber = null,
    Object? customerId = freezed,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? discountType = null,
    Object? taxAmount = null,
    Object? taxType = null,
    Object? total = null,
    Object? paidAmount = null,
    Object? balanceAmount = null,
    Object? paymentStatus = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? items = null,
    Object? payments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      taxType: null == taxType
          ? _value.taxType
          : taxType // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceAmount: null == balanceAmount
          ? _value.balanceAmount
          : balanceAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      payments: null == payments
          ? _value.payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvoiceImplCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$$InvoiceImplCopyWith(
          _$InvoiceImpl value, $Res Function(_$InvoiceImpl) then) =
      __$$InvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int invoiceNumber,
      String? customerId,
      double subtotal,
      double discountAmount,
      String discountType,
      double taxAmount,
      String taxType,
      double total,
      double paidAmount,
      double balanceAmount,
      String paymentStatus,
      String status,
      String? note,
      DateTime createdAt,
      DateTime updatedAt,
      List<InvoiceItem> items,
      List<Payment> payments});
}

/// @nodoc
class __$$InvoiceImplCopyWithImpl<$Res>
    extends _$InvoiceCopyWithImpl<$Res, _$InvoiceImpl>
    implements _$$InvoiceImplCopyWith<$Res> {
  __$$InvoiceImplCopyWithImpl(
      _$InvoiceImpl _value, $Res Function(_$InvoiceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNumber = null,
    Object? customerId = freezed,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? discountType = null,
    Object? taxAmount = null,
    Object? taxType = null,
    Object? total = null,
    Object? paidAmount = null,
    Object? balanceAmount = null,
    Object? paymentStatus = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? items = null,
    Object? payments = null,
  }) {
    return _then(_$InvoiceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      discountType: null == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as double,
      taxType: null == taxType
          ? _value.taxType
          : taxType // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceAmount: null == balanceAmount
          ? _value.balanceAmount
          : balanceAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      payments: null == payments
          ? _value._payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
    ));
  }
}

/// @nodoc

class _$InvoiceImpl extends _Invoice {
  const _$InvoiceImpl(
      {required this.id,
      required this.invoiceNumber,
      this.customerId,
      required this.subtotal,
      required this.discountAmount,
      required this.discountType,
      required this.taxAmount,
      required this.taxType,
      required this.total,
      required this.paidAmount,
      required this.balanceAmount,
      required this.paymentStatus,
      required this.status,
      this.note,
      required this.createdAt,
      required this.updatedAt,
      final List<InvoiceItem> items = const [],
      final List<Payment> payments = const []})
      : _items = items,
        _payments = payments,
        super._();

  @override
  final String id;
  @override
  final int invoiceNumber;
  @override
  final String? customerId;
  @override
  final double subtotal;
  @override
  final double discountAmount;
  @override
  final String discountType;
// 'FLAT' or 'PERCENTAGE'
  @override
  final double taxAmount;
  @override
  final String taxType;
  @override
  final double total;
  @override
  final double paidAmount;
  @override
  final double balanceAmount;
  @override
  final String paymentStatus;
// 'PAID', 'PARTIAL', 'UNPAID'
  @override
  final String status;
// 'ACTIVE', 'VOID'
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
// Relationships
  final List<InvoiceItem> _items;
// Relationships
  @override
  @JsonKey()
  List<InvoiceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<Payment> _payments;
  @override
  @JsonKey()
  List<Payment> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  String toString() {
    return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, customerId: $customerId, subtotal: $subtotal, discountAmount: $discountAmount, discountType: $discountType, taxAmount: $taxAmount, taxType: $taxType, total: $total, paidAmount: $paidAmount, balanceAmount: $balanceAmount, paymentStatus: $paymentStatus, status: $status, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, items: $items, payments: $payments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.taxType, taxType) || other.taxType == taxType) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.balanceAmount, balanceAmount) ||
                other.balanceAmount == balanceAmount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._payments, _payments));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      invoiceNumber,
      customerId,
      subtotal,
      discountAmount,
      discountType,
      taxAmount,
      taxType,
      total,
      paidAmount,
      balanceAmount,
      paymentStatus,
      status,
      note,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_payments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      __$$InvoiceImplCopyWithImpl<_$InvoiceImpl>(this, _$identity);
}

abstract class _Invoice extends Invoice {
  const factory _Invoice(
      {required final String id,
      required final int invoiceNumber,
      final String? customerId,
      required final double subtotal,
      required final double discountAmount,
      required final String discountType,
      required final double taxAmount,
      required final String taxType,
      required final double total,
      required final double paidAmount,
      required final double balanceAmount,
      required final String paymentStatus,
      required final String status,
      final String? note,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final List<InvoiceItem> items,
      final List<Payment> payments}) = _$InvoiceImpl;
  const _Invoice._() : super._();

  @override
  String get id;
  @override
  int get invoiceNumber;
  @override
  String? get customerId;
  @override
  double get subtotal;
  @override
  double get discountAmount;
  @override
  String get discountType;
  @override // 'FLAT' or 'PERCENTAGE'
  double get taxAmount;
  @override
  String get taxType;
  @override
  double get total;
  @override
  double get paidAmount;
  @override
  double get balanceAmount;
  @override
  String get paymentStatus;
  @override // 'PAID', 'PARTIAL', 'UNPAID'
  String get status;
  @override // 'ACTIVE', 'VOID'
  String? get note;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override // Relationships
  List<InvoiceItem> get items;
  @override
  List<Payment> get payments;
  @override
  @JsonKey(ignore: true)
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
