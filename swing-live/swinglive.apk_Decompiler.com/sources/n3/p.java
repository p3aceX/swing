package n3;

import java.util.ArrayList;
import x3.AbstractC0728h;
import x3.AbstractC0730j;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class p {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final k f5925b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final p[] f5926c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final int[] f5927d;
    public static final p e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final p f5928f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final p f5929m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ p[] f5930n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ B3.b f5931o;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f5932a;

    static {
        p pVar = new p("READ", 0, 1);
        e = pVar;
        p pVar2 = new p("WRITE", 1, 4);
        f5928f = pVar2;
        p pVar3 = new p("ACCEPT", 2, 16);
        p pVar4 = new p("CONNECT", 3, 8);
        f5929m = pVar4;
        p[] pVarArr = {pVar, pVar2, pVar3, pVar4};
        f5930n = pVarArr;
        B3.b bVarZ = H0.a.z(pVarArr);
        f5931o = bVarZ;
        f5925b = new k(3);
        f5926c = (p[]) J3.i.i(bVarZ, new p[0]);
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(bVarZ));
        J3.a aVar = new J3.a(bVarZ);
        while (aVar.hasNext()) {
            arrayList.add(Integer.valueOf(((p) aVar.next()).f5932a));
        }
        f5927d = AbstractC0728h.h0(arrayList);
        f5931o.f();
    }

    public p(String str, int i4, int i5) {
        this.f5932a = i5;
    }

    public static p valueOf(String str) {
        return (p) Enum.valueOf(p.class, str);
    }

    public static p[] values() {
        return (p[]) f5930n.clone();
    }
}
