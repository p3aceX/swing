package l1;

import D2.u;
import e1.AbstractC0367g;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/* JADX INFO: renamed from: l1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0522a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Set f5589a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Set f5590b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5591c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final d f5592d;
    public final Set e;

    public C0522a(Set set, Set set2, int i4, d dVar, Set set3) {
        this.f5589a = Collections.unmodifiableSet(set);
        this.f5590b = Collections.unmodifiableSet(set2);
        this.f5591c = i4;
        this.f5592d = dVar;
        this.e = Collections.unmodifiableSet(set3);
    }

    public static io.flutter.plugin.platform.f a(r rVar) {
        return new io.flutter.plugin.platform.f(rVar, new r[0]);
    }

    public static C0522a b(Object obj, Class cls, Class... clsArr) {
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        hashSet.add(r.a(cls));
        for (Class cls2 : clsArr) {
            AbstractC0367g.a(cls2, "Null interface");
            hashSet.add(r.a(cls2));
        }
        return new C0522a(new HashSet(hashSet), new HashSet(hashSet2), 0, new u(obj, 11), hashSet3);
    }

    public final String toString() {
        return "Component<" + Arrays.toString(this.f5589a.toArray()) + ">{0, type=" + this.f5591c + ", deps=" + Arrays.toString(this.f5590b.toArray()) + "}";
    }
}
