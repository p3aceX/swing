package S0;

import f1.C0400a;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public final class z extends AbstractC0155b {
    public static z b(j jVar, C0690c c0690c, Integer num) throws GeneralSecurityException {
        j jVar2 = j.f1757y;
        if (jVar != jVar2 && num == null) {
            throw new GeneralSecurityException("For given Variant " + jVar + " the value of idRequirement must be non-null");
        }
        if (jVar == jVar2 && num != null) {
            throw new GeneralSecurityException("For given Variant NO_PREFIX the value of idRequirement must be null");
        }
        C0400a c0400a = (C0400a) c0690c.f6642b;
        if (c0400a.f4284a.length != 32) {
            throw new GeneralSecurityException("XChaCha20Poly1305 key must be constructed with key of length 32 bytes, not " + c0400a.f4284a.length);
        }
        if (jVar == jVar2) {
            C0400a.a(new byte[0]);
        } else if (jVar == j.f1756x) {
            C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(num.intValue()).array());
        } else {
            if (jVar != j.f1755w) {
                throw new IllegalStateException("Unknown Variant: " + jVar);
            }
            C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(num.intValue()).array());
        }
        return new z();
    }
}
