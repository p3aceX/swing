package x1;

import java.security.spec.AlgorithmParameterSpec;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import l3.q;

/* JADX INFO: renamed from: x1.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0719d extends q {
    @Override // l3.q
    public final String c() {
        return "VGhpcyBpcyB0aGUga2V5IGZvcihBIHNlY3XyZZBzdG9yYWdlIEFFUyBLZXkK";
    }

    @Override // l3.q
    public final Cipher e() {
        return Cipher.getInstance("AES/GCM/NoPadding");
    }

    @Override // l3.q
    public final int f() {
        return 12;
    }

    @Override // l3.q
    public final AlgorithmParameterSpec g(byte[] bArr) {
        return new GCMParameterSpec(128, bArr);
    }
}
