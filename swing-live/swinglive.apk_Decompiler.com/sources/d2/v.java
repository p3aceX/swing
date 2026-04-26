package D2;

import I.C0053n;
import O.AbstractActivityC0114z;
import O.AbstractComponentCallbacksC0109u;
import android.animation.Animator;
import android.animation.AnimatorSet;
import android.content.pm.PackageManager;
import android.hardware.camera2.CameraManager;
import android.os.Bundle;
import android.util.Log;
import android.util.LongSparseArray;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.Animation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.io.PrintWriter;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CopyOnWriteArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import u1.C0690c;
import y0.C0740d;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class v implements D, O2.m, O2.c, O2.d, OnCompleteListener, T3.d {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static v f258d;
    public static F e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f259a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f260b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f261c;

    public /* synthetic */ v(int i4, Object obj, Object obj2) {
        this.f259a = i4;
        this.f261c = obj;
        this.f260b = obj2;
    }

    /* JADX WARN: Removed duplicated region for block: B:54:0x0083 A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:55:0x0084 A[RETURN] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static int e(D2.v r11, org.json.JSONArray r12) throws org.json.JSONException, java.lang.NoSuchFieldException {
        /*
            r11.getClass()
            r11 = 0
            r0 = r11
            r1 = r0
            r2 = r1
        L7:
            int r3 = r12.length()
            r4 = 2
            r5 = 4
            r6 = 1
            if (r0 >= r3) goto L6b
            java.lang.String r3 = r12.getString(r0)
            int[] r5 = K.j.c(r5)
            int r7 = r5.length
            r8 = r11
        L1a:
            if (r8 >= r7) goto L5f
            r9 = r5[r8]
            r10 = 1
            if (r9 == r10) goto L35
            r10 = 2
            if (r9 == r10) goto L32
            r10 = 3
            if (r9 == r10) goto L2f
            r10 = 4
            if (r9 != r10) goto L2d
            java.lang.String r10 = "DeviceOrientation.landscapeRight"
            goto L37
        L2d:
            r11 = 0
            throw r11
        L2f:
            java.lang.String r10 = "DeviceOrientation.landscapeLeft"
            goto L37
        L32:
            java.lang.String r10 = "DeviceOrientation.portraitDown"
            goto L37
        L35:
            java.lang.String r10 = "DeviceOrientation.portraitUp"
        L37:
            boolean r10 = r10.equals(r3)
            if (r10 == 0) goto L5c
            int r3 = K.j.b(r9)
            if (r3 == 0) goto L54
            if (r3 == r6) goto L51
            if (r3 == r4) goto L4e
            r4 = 3
            if (r3 == r4) goto L4b
            goto L56
        L4b:
            r1 = r1 | 8
            goto L56
        L4e:
            r1 = r1 | 2
            goto L56
        L51:
            r1 = r1 | 4
            goto L56
        L54:
            r1 = r1 | 1
        L56:
            if (r2 != 0) goto L59
            r2 = r1
        L59:
            int r0 = r0 + 1
            goto L7
        L5c:
            int r8 = r8 + 1
            goto L1a
        L5f:
            java.lang.NoSuchFieldException r11 = new java.lang.NoSuchFieldException
            java.lang.String r12 = "No such DeviceOrientation: "
            java.lang.String r12 = B1.a.m(r12, r3)
            r11.<init>(r12)
            throw r11
        L6b:
            if (r1 == 0) goto L88
            r12 = 8
            switch(r1) {
                case 2: goto L87;
                case 3: goto L7d;
                case 4: goto L85;
                case 5: goto L7a;
                case 6: goto L7d;
                case 7: goto L7d;
                case 8: goto L84;
                case 9: goto L7d;
                case 10: goto L77;
                case 11: goto L76;
                case 12: goto L7d;
                case 13: goto L7d;
                case 14: goto L7d;
                case 15: goto L73;
                default: goto L72;
            }
        L72:
            goto L83
        L73:
            r11 = 13
            return r11
        L76:
            return r4
        L77:
            r11 = 11
            return r11
        L7a:
            r11 = 12
            return r11
        L7d:
            if (r2 == r4) goto L87
            if (r2 == r5) goto L85
            if (r2 == r12) goto L84
        L83:
            return r6
        L84:
            return r12
        L85:
            r11 = 9
        L87:
            return r11
        L88:
            r11 = -1
            return r11
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.v.e(D2.v, org.json.JSONArray):int");
    }

    public static ArrayList h(v vVar, JSONArray jSONArray) throws JSONException, NoSuchFieldException {
        vVar.getClass();
        ArrayList arrayList = new ArrayList();
        for (int i4 = 0; i4 < jSONArray.length(); i4++) {
            String string = jSONArray.getString(i4);
            for (N2.d dVar : N2.d.values()) {
                if (dVar.f1138a.equals(string)) {
                    int iOrdinal = dVar.ordinal();
                    if (iOrdinal == 0) {
                        arrayList.add(N2.d.TOP_OVERLAYS);
                    } else if (iOrdinal == 1) {
                        arrayList.add(N2.d.BOTTOM_OVERLAYS);
                    }
                }
            }
            throw new NoSuchFieldException(B1.a.m("No such SystemUiOverlay: ", string));
        }
        return arrayList;
    }

    public static int i(v vVar, String str) throws NoSuchFieldException {
        String str2;
        vVar.getClass();
        for (int i4 : K.j.c(4)) {
            if (i4 == 1) {
                str2 = "SystemUiMode.leanBack";
            } else if (i4 == 2) {
                str2 = "SystemUiMode.immersive";
            } else if (i4 == 3) {
                str2 = "SystemUiMode.immersiveSticky";
            } else {
                if (i4 != 4) {
                    throw null;
                }
                str2 = "SystemUiMode.edgeToEdge";
            }
            if (str2.equals(str)) {
                int iB = K.j.b(i4);
                if (iB == 0) {
                    return 1;
                }
                if (iB != 1) {
                    return iB != 2 ? 4 : 3;
                }
                return 2;
            }
        }
        throw new NoSuchFieldException(B1.a.m("No such SystemUiMode: ", str));
    }

    public static J1.c j(v vVar, JSONObject jSONObject) {
        vVar.getClass();
        return new J1.c(!jSONObject.isNull("statusBarColor") ? Integer.valueOf(jSONObject.getInt("statusBarColor")) : null, !jSONObject.isNull("statusBarIconBrightness") ? B1.a.b(jSONObject.getString("statusBarIconBrightness")) : 0, !jSONObject.isNull("systemStatusBarContrastEnforced") ? Boolean.valueOf(jSONObject.getBoolean("systemStatusBarContrastEnforced")) : null, !jSONObject.isNull("systemNavigationBarColor") ? Integer.valueOf(jSONObject.getInt("systemNavigationBarColor")) : null, jSONObject.isNull("systemNavigationBarIconBrightness") ? 0 : B1.a.b(jSONObject.getString("systemNavigationBarIconBrightness")), !jSONObject.isNull("systemNavigationBarDividerColor") ? Integer.valueOf(jSONObject.getInt("systemNavigationBarDividerColor")) : null, jSONObject.isNull("systemNavigationBarContrastEnforced") ? null : Boolean.valueOf(jSONObject.getBoolean("systemNavigationBarContrastEnforced")));
    }

    public static HashMap k(String str, int i4, int i5, int i6, int i7) {
        HashMap map = new HashMap();
        map.put("text", str);
        map.put("selectionBase", Integer.valueOf(i4));
        map.put("selectionExtent", Integer.valueOf(i5));
        map.put("composingBase", Integer.valueOf(i6));
        map.put("composingExtent", Integer.valueOf(i7));
        return map;
    }

    public MotionEvent A(K k4) {
        PriorityQueue priorityQueue;
        LongSparseArray longSparseArray;
        long j4;
        while (true) {
            priorityQueue = (PriorityQueue) this.f261c;
            boolean zIsEmpty = priorityQueue.isEmpty();
            longSparseArray = (LongSparseArray) this.f260b;
            j4 = k4.f170a;
            if (zIsEmpty || ((Long) priorityQueue.peek()).longValue() >= j4) {
                break;
            }
            longSparseArray.remove(((Long) priorityQueue.poll()).longValue());
        }
        if (!priorityQueue.isEmpty() && ((Long) priorityQueue.peek()).longValue() == j4) {
            priorityQueue.poll();
        }
        MotionEvent motionEvent = (MotionEvent) longSparseArray.get(j4);
        longSparseArray.remove(j4);
        return motionEvent;
    }

    public void B(Y0.k kVar) throws GeneralSecurityException {
        Y0.l lVar = new Y0.l(kVar.f2482a, Z0.g.class);
        HashMap map = (HashMap) this.f260b;
        if (!map.containsKey(lVar)) {
            map.put(lVar, kVar);
            return;
        }
        Y0.k kVar2 = (Y0.k) map.get(lVar);
        if (kVar2.equals(kVar) && kVar.equals(kVar2)) {
            return;
        }
        throw new GeneralSecurityException("Attempt to register non-equal PrimitiveConstructor object for already existing object of type: " + lVar);
    }

    public void C(R0.n nVar) throws GeneralSecurityException {
        if (nVar == null) {
            throw new NullPointerException("wrapper must be non-null");
        }
        Class clsC = nVar.c();
        HashMap map = (HashMap) this.f261c;
        if (!map.containsKey(clsC)) {
            map.put(clsC, nVar);
            return;
        }
        R0.n nVar2 = (R0.n) map.get(clsC);
        if (nVar2.equals(nVar) && nVar.equals(nVar2)) {
            return;
        }
        throw new GeneralSecurityException("Attempt to register non-equal PrimitiveWrapper object or input class object for already existing object of type" + clsC);
    }

    @Override // D2.D
    public void a(KeyEvent keyEvent, B b5) {
        int action = keyEvent.getAction();
        if (action != 0 && action != 1) {
            b5.a(false);
            return;
        }
        Character chA = ((A) this.f261c).a(keyEvent.getUnicodeChar());
        boolean z4 = action != 0;
        u uVar = new u(b5, 0);
        C0690c c0690c = (C0690c) this.f260b;
        HashMap map = new HashMap();
        map.put("type", z4 ? "keyup" : "keydown");
        map.put("keymap", "android");
        map.put("flags", Integer.valueOf(keyEvent.getFlags()));
        map.put("plainCodePoint", Integer.valueOf(keyEvent.getUnicodeChar(0)));
        map.put("codePoint", Integer.valueOf(keyEvent.getUnicodeChar()));
        map.put("keyCode", Integer.valueOf(keyEvent.getKeyCode()));
        map.put("scanCode", Integer.valueOf(keyEvent.getScanCode()));
        map.put("metaState", Integer.valueOf(keyEvent.getMetaState()));
        map.put("character", chA.toString());
        map.put("source", Integer.valueOf(keyEvent.getSource()));
        map.put("deviceId", Integer.valueOf(keyEvent.getDeviceId()));
        map.put("repeatCount", Integer.valueOf(keyEvent.getRepeatCount()));
        ((C0053n) c0690c.f6642b).x(map, new u(uVar, 1));
    }

    /* JADX WARN: Removed duplicated region for block: B:28:0x0059  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x0063  */
    /* JADX WARN: Removed duplicated region for block: B:42:0x0095  */
    /* JADX WARN: Removed duplicated region for block: B:9:0x0018  */
    @Override // T3.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object b(T3.e r7, y3.InterfaceC0762c r8) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 264
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: D2.v.b(T3.e, y3.c):java.lang.Object");
    }

    @Override // O2.d
    public void c(ByteBuffer byteBuffer, F2.g gVar) {
        switch (this.f259a) {
            case 14:
                C0053n c0053n = (C0053n) this.f261c;
                try {
                    ((O2.b) this.f260b).d(((O2.l) c0053n.f708d).a(byteBuffer), new v(13, this, gVar));
                } catch (RuntimeException e4) {
                    Log.e("BasicMessageChannel#" + ((String) c0053n.f707c), "Failed to handle message", e4);
                    gVar.a(null);
                    return;
                }
                break;
            default:
                C0747k c0747k = (C0747k) this.f261c;
                try {
                    ((O2.m) this.f260b).g(((O2.n) c0747k.f6833d).c(byteBuffer), new N2.j(1, this, gVar));
                } catch (RuntimeException e5) {
                    Log.e("MethodChannel#" + ((String) c0747k.f6832c), "Failed to handle method call", e5);
                    gVar.a(((O2.n) c0747k.f6833d).e(e5.getMessage(), Log.getStackTraceString(e5)));
                }
                break;
        }
    }

    @Override // O2.c
    public void f(Object obj) {
        switch (this.f259a) {
            case 9:
                C0747k c0747k = (C0747k) this.f261c;
                ConcurrentLinkedQueue concurrentLinkedQueue = (ConcurrentLinkedQueue) c0747k.f6831b;
                N2.l lVar = (N2.l) this.f260b;
                concurrentLinkedQueue.remove(lVar);
                if (!((ConcurrentLinkedQueue) c0747k.f6831b).isEmpty()) {
                    Log.e("SettingsChannel", "The queue becomes empty after removing config generation " + lVar.f1175a);
                }
                break;
            default:
                ((F2.g) this.f260b).a(((O2.l) ((C0053n) ((v) this.f261c).f261c).f708d).b(obj));
                break;
        }
    }

    @Override // O2.m
    public void g(v vVar, N2.j jVar) {
        C0779j c0779j = (C0779j) this.f261c;
        if (((C0747k) c0779j.f6969b) == null) {
            jVar.c((Map) this.f260b);
            return;
        }
        String str = (String) vVar.f260b;
        str.getClass();
        if (!str.equals("getKeyboardState")) {
            jVar.b();
            return;
        }
        try {
            this.f260b = Collections.unmodifiableMap(((z) ((D[]) ((C0747k) c0779j.f6969b).f6831b)[0]).f274b);
        } catch (IllegalStateException e4) {
            jVar.a(null, "error", e4.getMessage());
        }
        jVar.c((Map) this.f260b);
    }

    public void l(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.l(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void m(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        O.N n4 = (O.N) this.f260b;
        AbstractActivityC0114z abstractActivityC0114z = n4.v.f1433c;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = n4.f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.m(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void n(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.n(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void o(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.o(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    @Override // com.google.android.gms.tasks.OnCompleteListener
    public void onComplete(Task task) {
        Q0.c cVar = (Q0.c) this.f260b;
        TaskCompletionSource taskCompletionSource = (TaskCompletionSource) this.f261c;
        synchronized (cVar.f1520f) {
            cVar.e.remove(taskCompletionSource);
        }
    }

    public void p(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.p(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void q(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.q(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void r(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        O.N n4 = (O.N) this.f260b;
        AbstractActivityC0114z abstractActivityC0114z = n4.v.f1433c;
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = n4.f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.r(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void s(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.s(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void t(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.t(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public String toString() {
        switch (this.f259a) {
            case 19:
                StringBuilder sb = new StringBuilder(128);
                sb.append("LoaderManager{");
                sb.append(Integer.toHexString(System.identityHashCode(this)));
                sb.append(" in ");
                Class<?> cls = ((androidx.lifecycle.n) this.f260b).getClass();
                sb.append(cls.getSimpleName());
                sb.append("{");
                sb.append(Integer.toHexString(System.identityHashCode(cls)));
                sb.append("}}");
                return sb.toString();
            default:
                return super.toString();
        }
    }

    public void u(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, Bundle bundle, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.u(abstractComponentCallbacksC0109u, bundle, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void v(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.v(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void w(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.w(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void x(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, boolean z4) {
        J3.i.e(abstractComponentCallbacksC0109u, "f");
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u2 = ((O.N) this.f260b).f1258x;
        if (abstractComponentCallbacksC0109u2 != null) {
            abstractComponentCallbacksC0109u2.o().f1249n.x(abstractComponentCallbacksC0109u, true);
        }
        Iterator it = ((CopyOnWriteArrayList) this.f261c).iterator();
        if (it.hasNext()) {
            if (it.next() != null) {
                throw new ClassCastException();
            }
            if (!z4) {
                throw null;
            }
            throw null;
        }
    }

    public void y(String str, PrintWriter printWriter) {
        R.b bVar = (R.b) this.f261c;
        if (bVar.f1677c.f5860c <= 0) {
            return;
        }
        printWriter.print(str);
        printWriter.println("Loaders:");
        String str2 = str + "    ";
        int i4 = 0;
        while (true) {
            n.l lVar = bVar.f1677c;
            if (i4 >= lVar.f5860c) {
                return;
            }
            R.a aVar = (R.a) lVar.f5859b[i4];
            printWriter.print(str);
            printWriter.print("  #");
            printWriter.print(bVar.f1677c.f5858a[i4]);
            printWriter.print(": ");
            printWriter.println(aVar.toString());
            printWriter.print(str2);
            printWriter.print("mId=");
            printWriter.print(0);
            printWriter.print(" mArgs=");
            printWriter.println((Object) null);
            printWriter.print(str2);
            printWriter.print("mLoader=");
            printWriter.println(aVar.f1674l);
            C0740d c0740d = aVar.f1674l;
            String str3 = str2 + "  ";
            c0740d.getClass();
            printWriter.print(str3);
            printWriter.print("mId=");
            printWriter.print(0);
            printWriter.print(" mListener=");
            printWriter.println(c0740d.f6813a);
            if (c0740d.f6814b || c0740d.e) {
                printWriter.print(str3);
                printWriter.print("mStarted=");
                printWriter.print(c0740d.f6814b);
                printWriter.print(" mContentChanged=");
                printWriter.print(c0740d.e);
                printWriter.print(" mProcessingChange=");
                printWriter.println(false);
            }
            if (c0740d.f6815c || c0740d.f6816d) {
                printWriter.print(str3);
                printWriter.print("mAbandoned=");
                printWriter.print(c0740d.f6815c);
                printWriter.print(" mReset=");
                printWriter.println(c0740d.f6816d);
            }
            if (c0740d.f6818g != null) {
                printWriter.print(str3);
                printWriter.print("mTask=");
                printWriter.print(c0740d.f6818g);
                printWriter.print(" waiting=");
                c0740d.f6818g.getClass();
                printWriter.println(false);
            }
            if (c0740d.f6819h != null) {
                printWriter.print(str3);
                printWriter.print("mCancellingTask=");
                printWriter.print(c0740d.f6819h);
                printWriter.print(" waiting=");
                c0740d.f6819h.getClass();
                printWriter.println(false);
            }
            if (aVar.f1676n != null) {
                printWriter.print(str2);
                printWriter.print("mCallbacks=");
                printWriter.println(aVar.f1676n);
                B b5 = aVar.f1676n;
                b5.getClass();
                printWriter.print(str2 + "  ");
                printWriter.print("mDeliveredData=");
                printWriter.println(b5.f155b);
            }
            printWriter.print(str2);
            printWriter.print("mData=");
            C0740d c0740d2 = aVar.f1674l;
            Object obj = aVar.e;
            Object obj2 = obj != androidx.lifecycle.u.f3089k ? obj : null;
            c0740d2.getClass();
            StringBuilder sb = new StringBuilder(64);
            if (obj2 == null) {
                sb.append("null");
            } else {
                Class<?> cls = obj2.getClass();
                sb.append(cls.getSimpleName());
                sb.append("{");
                sb.append(Integer.toHexString(System.identityHashCode(cls)));
                sb.append("}");
            }
            printWriter.println(sb.toString());
            printWriter.print(str2);
            printWriter.print("mStarted=");
            printWriter.println(aVar.f3092c > 0);
            i4++;
        }
    }

    public View z(int i4, int i5, int i6, int i7) {
        X.L l2 = (X.L) this.f260b;
        int i8 = l2.i();
        int iH = l2.h();
        int i9 = i5 > i4 ? 1 : -1;
        View view = null;
        while (i4 != i5) {
            View viewF = l2.f(i4);
            int iP = l2.p(viewF);
            int iJ = l2.j(viewF);
            X.K k4 = (X.K) this.f261c;
            k4.f2304b = i8;
            k4.f2305c = iH;
            k4.f2306d = iP;
            k4.e = iJ;
            if (i6 != 0) {
                k4.f2303a = i6;
                if (k4.a()) {
                    return viewF;
                }
            }
            if (i7 != 0) {
                k4.f2303a = i7;
                if (k4.a()) {
                    view = viewF;
                }
            }
            i4 += i9;
        }
        return view;
    }

    public /* synthetic */ v(Object obj, Object obj2, int i4, boolean z4) {
        this.f259a = i4;
        this.f260b = obj;
        this.f261c = obj2;
    }

    public v(String str) {
        this.f259a = 29;
        this.f260b = "LibraryVersion";
        this.f261c = (str == null || str.length() <= 0) ? null : str;
    }

    public v(Q2.a aVar, C0779j c0779j) {
        this.f259a = 18;
        this.f260b = aVar;
        this.f261c = c0779j;
        c0779j.f6969b = new C0690c(this, 17);
    }

    public v(O.N n4) {
        this.f259a = 12;
        J3.i.e(n4, "fragmentManager");
        this.f260b = n4;
        this.f261c = new CopyOnWriteArrayList();
    }

    public v(C0690c c0690c) {
        this.f259a = 0;
        this.f261c = new A();
        this.f260b = c0690c;
    }

    public v(C0779j c0779j) {
        this.f259a = 3;
        this.f261c = c0779j;
        this.f260b = new HashMap();
    }

    public v(String str, CameraManager cameraManager) {
        this.f259a = 21;
        this.f261c = str;
        this.f260b = cameraManager.getCameraCharacteristics(str);
    }

    public v(androidx.lifecycle.n nVar, androidx.lifecycle.H h4) {
        R.b bVar;
        this.f259a = 19;
        this.f260b = nVar;
        J3.i.e(h4, "store");
        Q.a aVar = Q.a.f1508b;
        J3.i.e(aVar, "defaultCreationExtras");
        String canonicalName = R.b.class.getCanonicalName();
        if (canonicalName != null) {
            String strConcat = "androidx.lifecycle.ViewModelProvider.DefaultKey:".concat(canonicalName);
            J3.i.e(strConcat, "key");
            LinkedHashMap linkedHashMap = h4.f3062a;
            androidx.lifecycle.F f4 = (androidx.lifecycle.F) linkedHashMap.get(strConcat);
            if (R.b.class.isInstance(f4)) {
                J3.i.c(f4, "null cannot be cast to non-null type T of androidx.lifecycle.ViewModelProvider.get");
            } else {
                Q.c cVar = new Q.c(aVar);
                ((LinkedHashMap) cVar.f1509a).put(androidx.lifecycle.G.f3061b, strConcat);
                try {
                    bVar = new R.b();
                } catch (AbstractMethodError unused) {
                    bVar = new R.b();
                }
                f4 = bVar;
                androidx.lifecycle.F f5 = (androidx.lifecycle.F) linkedHashMap.put(strConcat, f4);
                if (f5 != null) {
                    f5.a();
                }
            }
            this.f261c = (R.b) f4;
            return;
        }
        throw new IllegalArgumentException("Local and anonymous classes can not be ViewModels");
    }

    public v(Y0.m mVar) {
        this.f259a = 28;
        this.f260b = new HashMap(mVar.f2486a);
        this.f261c = new HashMap(mVar.f2487b);
    }

    public v(int i4) {
        this.f259a = i4;
        switch (i4) {
            case 2:
                break;
            case 28:
                this.f260b = new HashMap();
                this.f261c = new HashMap();
                break;
            default:
                this.f260b = new LongSparseArray();
                this.f261c = new PriorityQueue();
                break;
        }
    }

    public v(F2.b bVar, int i4) {
        this.f259a = i4;
        switch (i4) {
            case 5:
                C0690c c0690c = new C0690c(this, 10);
                C0747k c0747k = new C0747k(bVar, "flutter/platform", O2.k.f1454a, 11);
                this.f260b = c0747k;
                c0747k.Y(c0690c);
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                B.k kVar = new B.k(this, 9);
                C0747k c0747k2 = new C0747k(bVar, "flutter/platform_views_2", O2.r.f1458a, 11);
                this.f260b = c0747k2;
                c0747k2.Y(kVar);
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                C0779j c0779j = new C0779j(this, 10);
                C0747k c0747k3 = new C0747k(bVar, "flutter/platform_views", O2.r.f1458a, 11);
                this.f260b = c0747k3;
                c0747k3.Y(c0779j);
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
            case 9:
            default:
                B.k kVar2 = new B.k(this, 7);
                C0747k c0747k4 = new C0747k(bVar, "flutter/localization", O2.k.f1454a, 11);
                this.f260b = c0747k4;
                c0747k4.Y(kVar2);
                break;
            case 10:
                C0690c c0690c2 = new C0690c(this, 14);
                C0747k c0747k5 = new C0747k(bVar, "flutter/textinput", O2.k.f1454a, 11);
                this.f260b = c0747k5;
                c0747k5.Y(c0690c2);
                break;
        }
    }

    public v(F2.b bVar, PackageManager packageManager) {
        this.f259a = 8;
        C0690c c0690c = new C0690c(this, 11);
        this.f260b = packageManager;
        new C0747k(bVar, "flutter/processtext", O2.r.f1458a, 11).Y(c0690c);
    }

    public v(X.L l2) {
        this.f259a = 27;
        this.f260b = l2;
        X.K k4 = new X.K();
        k4.f2303a = 0;
        this.f261c = k4;
    }

    public v(Animation animation) {
        this.f259a = 11;
        this.f260b = animation;
        this.f261c = null;
    }

    public v(Animator animator) {
        this.f259a = 11;
        this.f260b = null;
        AnimatorSet animatorSet = new AnimatorSet();
        this.f261c = animatorSet;
        animatorSet.play(animator);
    }

    public v(O2.f fVar, String str) {
        this.f259a = 22;
        this.f260b = fVar;
        this.f261c = str.isEmpty() ? "" : ".".concat(str);
    }
}
