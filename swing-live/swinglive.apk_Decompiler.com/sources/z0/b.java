package Z0;

import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import d1.C0328a;
import d1.C0329b;
import d1.C0330c;
import d1.C0331d;
import d1.C0332e;
import d1.C0333f;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class b extends Q.b {
    @Override // Q.b
    public final AbstractC0296a a(AbstractC0296a abstractC0296a) {
        C0331d c0331d = (C0331d) abstractC0296a;
        C0328a c0328aC = C0329b.C();
        c0328aC.e();
        C0329b.w((C0329b) c0328aC.f3838b);
        byte[] bArrA = e1.p.a(c0331d.y());
        C0302g c0302gH = AbstractC0303h.h(bArrA, 0, bArrA.length);
        c0328aC.e();
        C0329b.x((C0329b) c0328aC.f3838b, c0302gH);
        C0333f c0333fZ = c0331d.z();
        c0328aC.e();
        C0329b.y((C0329b) c0328aC.f3838b, c0333fZ);
        return (C0329b) c0328aC.b();
    }

    @Override // Q.b
    public final Map h() {
        HashMap map = new HashMap();
        C0330c c0330cA = C0331d.A();
        c0330cA.e();
        C0331d.w((C0331d) c0330cA.f3838b);
        C0332e c0332eZ = C0333f.z();
        c0332eZ.e();
        C0333f.w((C0333f) c0332eZ.f3838b);
        C0333f c0333f = (C0333f) c0332eZ.b();
        c0330cA.e();
        C0331d.x((C0331d) c0330cA.f3838b, c0333f);
        map.put("AES_CMAC", new Y0.c((C0331d) c0330cA.b(), 1));
        C0330c c0330cA2 = C0331d.A();
        c0330cA2.e();
        C0331d.w((C0331d) c0330cA2.f3838b);
        C0332e c0332eZ2 = C0333f.z();
        c0332eZ2.e();
        C0333f.w((C0333f) c0332eZ2.f3838b);
        C0333f c0333f2 = (C0333f) c0332eZ2.b();
        c0330cA2.e();
        C0331d.x((C0331d) c0330cA2.f3838b, c0333f2);
        map.put("AES256_CMAC", new Y0.c((C0331d) c0330cA2.b(), 1));
        C0330c c0330cA3 = C0331d.A();
        c0330cA3.e();
        C0331d.w((C0331d) c0330cA3.f3838b);
        C0332e c0332eZ3 = C0333f.z();
        c0332eZ3.e();
        C0333f.w((C0333f) c0332eZ3.f3838b);
        C0333f c0333f3 = (C0333f) c0332eZ3.b();
        c0330cA3.e();
        C0331d.x((C0331d) c0330cA3.f3838b, c0333f3);
        map.put("AES256_CMAC_RAW", new Y0.c((C0331d) c0330cA3.b(), 3));
        return Collections.unmodifiableMap(map);
    }

    @Override // Q.b
    public final AbstractC0296a i(AbstractC0303h abstractC0303h) {
        return C0331d.B(abstractC0303h, C0309n.a());
    }

    @Override // Q.b
    public final void j(AbstractC0296a abstractC0296a) throws GeneralSecurityException {
        C0331d c0331d = (C0331d) abstractC0296a;
        c.t(c0331d.z());
        if (c0331d.y() != 32) {
            throw new GeneralSecurityException("AesCmacKey size wrong, must be 32 bytes");
        }
    }
}
