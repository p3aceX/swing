package W0;

import A.C0003c;
import Y0.i;
import Y0.j;
import Y0.s;
import d1.r0;
import f1.C0400a;
import java.util.Collections;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final j f2262a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final i f2263b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Y0.b f2264c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Y0.a f2265d;
    public static final Map e;

    static {
        C0400a c0400aB = s.b("type.googleapis.com/google.crypto.tink.AesSivKey");
        f2262a = new j(c.class);
        f2263b = new i(c0400aB);
        f2264c = new Y0.b(a.class);
        f2265d = new Y0.a(c0400aB, new C0003c(9));
        HashMap map = new HashMap();
        b bVar = b.f2258d;
        r0 r0Var = r0.RAW;
        map.put(bVar, r0Var);
        b bVar2 = b.f2256b;
        r0 r0Var2 = r0.TINK;
        map.put(bVar2, r0Var2);
        b bVar3 = b.f2257c;
        r0 r0Var3 = r0.CRUNCHY;
        map.put(bVar3, r0Var3);
        Collections.unmodifiableMap(map);
        EnumMap enumMap = new EnumMap(r0.class);
        enumMap.put(r0Var, bVar);
        enumMap.put(r0Var2, bVar2);
        enumMap.put(r0Var3, bVar3);
        enumMap.put(r0.LEGACY, bVar3);
        e = Collections.unmodifiableMap(enumMap);
    }
}
