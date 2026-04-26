package o3;

import q3.EnumC0636a;
import q3.EnumC0642g;

/* JADX INFO: renamed from: o3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0594b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final short f6066a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6067b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6068c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final EnumC0604l f6069d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f6070f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f6071g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final int f6072h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final int f6073i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final String f6074j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final int f6075k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final EnumC0636a f6076l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final EnumC0642g f6077m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final EnumC0595c f6078n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int f6079o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final int f6080p;

    public C0594b(short s4, String str, String str2, EnumC0604l enumC0604l, String str3, int i4, int i5, int i6, int i7, String str4, int i8, EnumC0636a enumC0636a, EnumC0642g enumC0642g, EnumC0595c enumC0595c) {
        this.f6066a = s4;
        this.f6067b = str;
        this.f6068c = str2;
        this.f6069d = enumC0604l;
        this.e = str3;
        this.f6070f = i4;
        this.f6071g = i5;
        this.f6072h = i6;
        this.f6073i = i7;
        this.f6074j = str4;
        this.f6075k = i8;
        this.f6076l = enumC0636a;
        this.f6077m = enumC0642g;
        this.f6078n = enumC0595c;
        this.f6079o = i4 / 8;
        this.f6080p = i8 / 8;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0594b)) {
            return false;
        }
        C0594b c0594b = (C0594b) obj;
        return this.f6066a == c0594b.f6066a && J3.i.a(this.f6067b, c0594b.f6067b) && J3.i.a(this.f6068c, c0594b.f6068c) && this.f6069d == c0594b.f6069d && J3.i.a(this.e, c0594b.e) && this.f6070f == c0594b.f6070f && this.f6071g == c0594b.f6071g && this.f6072h == c0594b.f6072h && this.f6073i == c0594b.f6073i && J3.i.a(this.f6074j, c0594b.f6074j) && this.f6075k == c0594b.f6075k && this.f6076l == c0594b.f6076l && this.f6077m == c0594b.f6077m && this.f6078n == c0594b.f6078n;
    }

    public final int hashCode() {
        return this.f6078n.hashCode() + ((this.f6077m.hashCode() + ((this.f6076l.hashCode() + B1.a.h(this.f6075k, (this.f6074j.hashCode() + B1.a.h(this.f6073i, B1.a.h(this.f6072h, B1.a.h(this.f6071g, B1.a.h(this.f6070f, (this.e.hashCode() + ((this.f6069d.hashCode() + ((this.f6068c.hashCode() + ((this.f6067b.hashCode() + (Short.hashCode(this.f6066a) * 31)) * 31)) * 31)) * 31)) * 31, 31), 31), 31), 31)) * 31, 31)) * 31)) * 31);
    }

    public final String toString() {
        return "CipherSuite(code=" + ((int) this.f6066a) + ", name=" + this.f6067b + ", openSSLName=" + this.f6068c + ", exchangeType=" + this.f6069d + ", jdkCipherName=" + this.e + ", keyStrength=" + this.f6070f + ", fixedIvLength=" + this.f6071g + ", ivLength=" + this.f6072h + ", cipherTagSizeInBytes=" + this.f6073i + ", macName=" + this.f6074j + ", macStrength=" + this.f6075k + ", hash=" + this.f6076l + ", signatureAlgorithm=" + this.f6077m + ", cipherType=" + this.f6078n + ')';
    }

    public /* synthetic */ C0594b(short s4, String str, String str2, EnumC0604l enumC0604l, int i4, EnumC0636a enumC0636a, EnumC0642g enumC0642g) {
        this(s4, str, str2, enumC0604l, "AES/GCM/NoPadding", i4, 4, 12, 16, "AEAD", 0, enumC0636a, enumC0642g, EnumC0595c.f6081a);
    }
}
