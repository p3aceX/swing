package O;

import android.util.Log;
import java.io.PrintWriter;
import java.lang.reflect.Modifier;
import java.util.ArrayList;

/* JADX INFO: renamed from: O.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0090a implements K {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f1304a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1305b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f1306c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1307d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f1308f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f1309g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public String f1310h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f1311i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public CharSequence f1312j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f1313k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public CharSequence f1314l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ArrayList f1315m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public ArrayList f1316n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f1317o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final N f1318p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public boolean f1319q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f1320r;

    public C0090a(N n4) {
        n4.G();
        C0113y c0113y = n4.v;
        if (c0113y != null) {
            c0113y.f1433c.getClassLoader();
        }
        this.f1304a = new ArrayList();
        this.f1317o = false;
        this.f1320r = -1;
        this.f1318p = n4;
    }

    @Override // O.K
    public final boolean a(ArrayList arrayList, ArrayList arrayList2) {
        if (N.J(2)) {
            Log.v("FragmentManager", "Run: " + this);
        }
        arrayList.add(this);
        arrayList2.add(Boolean.FALSE);
        if (!this.f1309g) {
            return true;
        }
        this.f1318p.f1240d.add(this);
        return true;
    }

    public final void b(V v) {
        this.f1304a.add(v);
        v.f1294d = this.f1305b;
        v.e = this.f1306c;
        v.f1295f = this.f1307d;
        v.f1296g = this.e;
    }

    public final void c(int i4) {
        if (this.f1309g) {
            if (N.J(2)) {
                Log.v("FragmentManager", "Bump nesting in " + this + " by " + i4);
            }
            ArrayList arrayList = this.f1304a;
            int size = arrayList.size();
            for (int i5 = 0; i5 < size; i5++) {
                V v = (V) arrayList.get(i5);
                AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = v.f1292b;
                if (abstractComponentCallbacksC0109u != null) {
                    abstractComponentCallbacksC0109u.f1423x += i4;
                    if (N.J(2)) {
                        Log.v("FragmentManager", "Bump nesting of " + v.f1292b + " to " + v.f1292b.f1423x);
                    }
                }
            }
        }
    }

    public final int d(boolean z4) {
        if (this.f1319q) {
            throw new IllegalStateException("commit already called");
        }
        if (N.J(2)) {
            Log.v("FragmentManager", "Commit: " + this);
            PrintWriter printWriter = new PrintWriter(new X());
            f("  ", printWriter, true);
            printWriter.close();
        }
        this.f1319q = true;
        boolean z5 = this.f1309g;
        N n4 = this.f1318p;
        if (z5) {
            this.f1320r = n4.f1245j.getAndIncrement();
        } else {
            this.f1320r = -1;
        }
        n4.x(this, z4);
        return this.f1320r;
    }

    public final void e(int i4, AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, String str) {
        String str2 = abstractComponentCallbacksC0109u.f1401Q;
        if (str2 != null) {
            P.d.c(abstractComponentCallbacksC0109u, str2);
        }
        Class<?> cls = abstractComponentCallbacksC0109u.getClass();
        int modifiers = cls.getModifiers();
        if (cls.isAnonymousClass() || !Modifier.isPublic(modifiers) || (cls.isMemberClass() && !Modifier.isStatic(modifiers))) {
            throw new IllegalStateException("Fragment " + cls.getCanonicalName() + " must be a public static class to be  properly recreated from instance state.");
        }
        if (str != null) {
            String str3 = abstractComponentCallbacksC0109u.f1390E;
            if (str3 != null && !str.equals(str3)) {
                throw new IllegalStateException("Can't change tag of fragment " + abstractComponentCallbacksC0109u + ": was " + abstractComponentCallbacksC0109u.f1390E + " now " + str);
            }
            abstractComponentCallbacksC0109u.f1390E = str;
        }
        if (i4 != 0) {
            if (i4 == -1) {
                throw new IllegalArgumentException("Can't add fragment " + abstractComponentCallbacksC0109u + " with tag " + str + " to container view with no id");
            }
            int i5 = abstractComponentCallbacksC0109u.f1388C;
            if (i5 != 0 && i5 != i4) {
                throw new IllegalStateException("Can't change container ID of fragment " + abstractComponentCallbacksC0109u + ": was " + abstractComponentCallbacksC0109u.f1388C + " now " + i4);
            }
            abstractComponentCallbacksC0109u.f1388C = i4;
            abstractComponentCallbacksC0109u.f1389D = i4;
        }
        b(new V(1, abstractComponentCallbacksC0109u));
        abstractComponentCallbacksC0109u.f1424y = this.f1318p;
    }

    public final void f(String str, PrintWriter printWriter, boolean z4) {
        String str2;
        if (z4) {
            printWriter.print(str);
            printWriter.print("mName=");
            printWriter.print(this.f1310h);
            printWriter.print(" mIndex=");
            printWriter.print(this.f1320r);
            printWriter.print(" mCommitted=");
            printWriter.println(this.f1319q);
            if (this.f1308f != 0) {
                printWriter.print(str);
                printWriter.print("mTransition=#");
                printWriter.print(Integer.toHexString(this.f1308f));
            }
            if (this.f1305b != 0 || this.f1306c != 0) {
                printWriter.print(str);
                printWriter.print("mEnterAnim=#");
                printWriter.print(Integer.toHexString(this.f1305b));
                printWriter.print(" mExitAnim=#");
                printWriter.println(Integer.toHexString(this.f1306c));
            }
            if (this.f1307d != 0 || this.e != 0) {
                printWriter.print(str);
                printWriter.print("mPopEnterAnim=#");
                printWriter.print(Integer.toHexString(this.f1307d));
                printWriter.print(" mPopExitAnim=#");
                printWriter.println(Integer.toHexString(this.e));
            }
            if (this.f1311i != 0 || this.f1312j != null) {
                printWriter.print(str);
                printWriter.print("mBreadCrumbTitleRes=#");
                printWriter.print(Integer.toHexString(this.f1311i));
                printWriter.print(" mBreadCrumbTitleText=");
                printWriter.println(this.f1312j);
            }
            if (this.f1313k != 0 || this.f1314l != null) {
                printWriter.print(str);
                printWriter.print("mBreadCrumbShortTitleRes=#");
                printWriter.print(Integer.toHexString(this.f1313k));
                printWriter.print(" mBreadCrumbShortTitleText=");
                printWriter.println(this.f1314l);
            }
        }
        ArrayList arrayList = this.f1304a;
        if (arrayList.isEmpty()) {
            return;
        }
        printWriter.print(str);
        printWriter.println("Operations:");
        int size = arrayList.size();
        for (int i4 = 0; i4 < size; i4++) {
            V v = (V) arrayList.get(i4);
            switch (v.f1291a) {
                case 0:
                    str2 = "NULL";
                    break;
                case 1:
                    str2 = "ADD";
                    break;
                case 2:
                    str2 = "REPLACE";
                    break;
                case 3:
                    str2 = "REMOVE";
                    break;
                case 4:
                    str2 = "HIDE";
                    break;
                case 5:
                    str2 = "SHOW";
                    break;
                case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                    str2 = "DETACH";
                    break;
                case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                    str2 = "ATTACH";
                    break;
                case K.k.BYTES_FIELD_NUMBER /* 8 */:
                    str2 = "SET_PRIMARY_NAV";
                    break;
                case 9:
                    str2 = "UNSET_PRIMARY_NAV";
                    break;
                case 10:
                    str2 = "OP_SET_MAX_LIFECYCLE";
                    break;
                default:
                    str2 = "cmd=" + v.f1291a;
                    break;
            }
            printWriter.print(str);
            printWriter.print("  Op #");
            printWriter.print(i4);
            printWriter.print(": ");
            printWriter.print(str2);
            printWriter.print(" ");
            printWriter.println(v.f1292b);
            if (z4) {
                if (v.f1294d != 0 || v.e != 0) {
                    printWriter.print(str);
                    printWriter.print("enterAnim=#");
                    printWriter.print(Integer.toHexString(v.f1294d));
                    printWriter.print(" exitAnim=#");
                    printWriter.println(Integer.toHexString(v.e));
                }
                if (v.f1295f != 0 || v.f1296g != 0) {
                    printWriter.print(str);
                    printWriter.print("popEnterAnim=#");
                    printWriter.print(Integer.toHexString(v.f1295f));
                    printWriter.print(" popExitAnim=#");
                    printWriter.println(Integer.toHexString(v.f1296g));
                }
            }
        }
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder(128);
        sb.append("BackStackEntry{");
        sb.append(Integer.toHexString(System.identityHashCode(this)));
        if (this.f1320r >= 0) {
            sb.append(" #");
            sb.append(this.f1320r);
        }
        if (this.f1310h != null) {
            sb.append(" ");
            sb.append(this.f1310h);
        }
        sb.append("}");
        return sb.toString();
    }
}
