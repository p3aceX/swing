package o3;

import java.security.PrivateKey;
import java.security.PublicKey;

/* JADX INFO: renamed from: o3.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0597e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final PublicKey f6085a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final PublicKey f6086b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final PrivateKey f6087c;

    public C0597e(PublicKey publicKey, PublicKey publicKey2, PrivateKey privateKey) {
        this.f6085a = publicKey;
        this.f6086b = publicKey2;
        this.f6087c = privateKey;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0597e)) {
            return false;
        }
        C0597e c0597e = (C0597e) obj;
        return J3.i.a(this.f6085a, c0597e.f6085a) && J3.i.a(this.f6086b, c0597e.f6086b) && J3.i.a(this.f6087c, c0597e.f6087c);
    }

    public final int hashCode() {
        return this.f6087c.hashCode() + ((this.f6086b.hashCode() + (this.f6085a.hashCode() * 31)) * 31);
    }

    public final String toString() {
        return "EncryptionInfo(serverPublic=" + this.f6085a + ", clientPublic=" + this.f6086b + ", clientPrivate=" + this.f6087c + ')';
    }
}
