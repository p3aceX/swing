package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: o3.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0607o {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final X.N f6125b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0607o[] f6126c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0607o f6127d;
    public static final /* synthetic */ EnumC0607o[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6128f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6129a;

    /* JADX WARN: Multi-variable type inference failed */
    static {
        Object next;
        EnumC0607o enumC0607o = new EnumC0607o("DecryptionFailed_RESERVED", 0, 21);
        EnumC0607o enumC0607o2 = new EnumC0607o("CloseNotify", 1, 0);
        f6127d = enumC0607o2;
        EnumC0607o[] enumC0607oArr = {enumC0607o, enumC0607o2, new EnumC0607o("UnexpectedMessage", 2, 10), new EnumC0607o("BadRecordMac", 3, 20), new EnumC0607o("RecordOverflow", 4, 22), new EnumC0607o("DecompressionFailure", 5, 30), new EnumC0607o("HandshakeFailure", 6, 40), new EnumC0607o("NoCertificate_RESERVED", 7, 41), new EnumC0607o("BadCertificate", 8, 42), new EnumC0607o("UnsupportedCertificate", 9, 43), new EnumC0607o("CertificateRevoked", 10, 44), new EnumC0607o("CertificateExpired", 11, 45), new EnumC0607o("CertificateUnknown", 12, 46), new EnumC0607o("IllegalParameter", 13, 47), new EnumC0607o("UnknownCa", 14, 48), new EnumC0607o("AccessDenied", 15, 49), new EnumC0607o("DecodeError", 16, 50), new EnumC0607o("DecryptError", 17, 51), new EnumC0607o("ExportRestriction_RESERVED", 18, 60), new EnumC0607o("ProtocolVersion", 19, 70), new EnumC0607o("InsufficientSecurity", 20, 71), new EnumC0607o("InternalError", 21, 80), new EnumC0607o("UserCanceled", 22, 90), new EnumC0607o("NoRenegotiation", 23, 100), new EnumC0607o("UnsupportedExtension", 24, 110)};
        e = enumC0607oArr;
        f6128f = H0.a.z(enumC0607oArr);
        f6125b = new X.N(29);
        EnumC0607o[] enumC0607oArr2 = new EnumC0607o[256];
        for (int i4 = 0; i4 < 256; i4++) {
            B3.b bVar = f6128f;
            bVar.getClass();
            J3.a aVar = new J3.a(bVar);
            while (true) {
                if (aVar.hasNext()) {
                    next = aVar.next();
                    if (((EnumC0607o) next).f6129a == i4) {
                        break;
                    }
                } else {
                    next = null;
                    break;
                }
            }
            enumC0607oArr2[i4] = next;
        }
        f6126c = enumC0607oArr2;
    }

    public EnumC0607o(String str, int i4, int i5) {
        this.f6129a = i5;
    }

    public static EnumC0607o valueOf(String str) {
        return (EnumC0607o) Enum.valueOf(EnumC0607o.class, str);
    }

    public static EnumC0607o[] values() {
        return (EnumC0607o[]) e.clone();
    }
}
