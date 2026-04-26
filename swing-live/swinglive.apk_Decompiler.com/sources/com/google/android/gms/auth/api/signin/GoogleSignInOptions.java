package com.google.android.gms.auth.api.signin;

import A0.a;
import a.AbstractC0184a;
import android.accounts.Account;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.api.e;
import com.google.android.gms.common.internal.ReflectedParcelable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import org.json.JSONArray;
import org.json.JSONObject;
import x0.d;
import y0.C0737a;

/* JADX INFO: loaded from: classes.dex */
public class GoogleSignInOptions extends a implements e, ReflectedParcelable {
    public static final Parcelable.Creator<GoogleSignInOptions> CREATOR;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final GoogleSignInOptions f3342q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final GoogleSignInOptions f3343r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static final Scope f3344s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public static final Scope f3345t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public static final Scope f3346u;
    public static final Scope v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public static final d f3347w;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3348a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f3349b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Account f3350c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f3351d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final boolean f3352f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f3353m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final String f3354n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final ArrayList f3355o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final String f3356p;

    static {
        Scope scope = new Scope(1, "profile");
        f3344s = new Scope(1, "email");
        Scope scope2 = new Scope(1, "openid");
        f3345t = scope2;
        Scope scope3 = new Scope(1, "https://www.googleapis.com/auth/games_lite");
        f3346u = scope3;
        v = new Scope(1, "https://www.googleapis.com/auth/games");
        HashSet hashSet = new HashSet();
        HashMap map = new HashMap();
        hashSet.add(scope2);
        hashSet.add(scope);
        if (hashSet.contains(v)) {
            Scope scope4 = f3346u;
            if (hashSet.contains(scope4)) {
                hashSet.remove(scope4);
            }
        }
        f3342q = new GoogleSignInOptions(3, new ArrayList(hashSet), null, false, false, false, null, null, map, null);
        HashSet hashSet2 = new HashSet();
        HashMap map2 = new HashMap();
        hashSet2.add(scope3);
        hashSet2.addAll(Arrays.asList(new Scope[0]));
        if (hashSet2.contains(v)) {
            Scope scope5 = f3346u;
            if (hashSet2.contains(scope5)) {
                hashSet2.remove(scope5);
            }
        }
        f3343r = new GoogleSignInOptions(3, new ArrayList(hashSet2), null, false, false, false, null, null, map2, null);
        CREATOR = new x0.e(1);
        f3347w = new d(1);
    }

    public GoogleSignInOptions(int i4, ArrayList arrayList, Account account, boolean z4, boolean z5, boolean z6, String str, String str2, HashMap map, String str3) {
        this.f3348a = i4;
        this.f3349b = arrayList;
        this.f3350c = account;
        this.f3351d = z4;
        this.e = z5;
        this.f3352f = z6;
        this.f3353m = str;
        this.f3354n = str2;
        this.f3355o = new ArrayList(map.values());
        this.f3356p = str3;
    }

    public static GoogleSignInOptions c(String str) {
        if (TextUtils.isEmpty(str)) {
            return null;
        }
        JSONObject jSONObject = new JSONObject(str);
        HashSet hashSet = new HashSet();
        JSONArray jSONArray = jSONObject.getJSONArray("scopes");
        int length = jSONArray.length();
        for (int i4 = 0; i4 < length; i4++) {
            hashSet.add(new Scope(1, jSONArray.getString(i4)));
        }
        String strOptString = jSONObject.has("accountName") ? jSONObject.optString("accountName") : null;
        return new GoogleSignInOptions(3, new ArrayList(hashSet), !TextUtils.isEmpty(strOptString) ? new Account(strOptString, "com.google") : null, jSONObject.getBoolean("idTokenRequested"), jSONObject.getBoolean("serverAuthRequested"), jSONObject.getBoolean("forceCodeForRefreshToken"), jSONObject.has("serverClientId") ? jSONObject.optString("serverClientId") : null, jSONObject.has("hostedDomain") ? jSONObject.optString("hostedDomain") : null, new HashMap(), null);
    }

    public static HashMap d(ArrayList arrayList) {
        HashMap map = new HashMap();
        if (arrayList != null) {
            Iterator it = arrayList.iterator();
            while (it.hasNext()) {
                C0737a c0737a = (C0737a) it.next();
                map.put(Integer.valueOf(c0737a.f6804b), c0737a);
            }
        }
        return map;
    }

    public final ArrayList b() {
        return new ArrayList(this.f3349b);
    }

    /* JADX WARN: Removed duplicated region for block: B:23:0x004b A[Catch: ClassCastException -> 0x0077, TryCatch #0 {ClassCastException -> 0x0077, blocks: (B:5:0x0008, B:7:0x0016, B:10:0x001f, B:12:0x002d, B:15:0x0038, B:21:0x0045, B:23:0x004b, B:29:0x0059, B:31:0x005f, B:33:0x0065, B:35:0x006b, B:26:0x0052, B:19:0x003f), top: B:41:0x0008 }] */
    /* JADX WARN: Removed duplicated region for block: B:26:0x0052 A[Catch: ClassCastException -> 0x0077, TryCatch #0 {ClassCastException -> 0x0077, blocks: (B:5:0x0008, B:7:0x0016, B:10:0x001f, B:12:0x002d, B:15:0x0038, B:21:0x0045, B:23:0x004b, B:29:0x0059, B:31:0x005f, B:33:0x0065, B:35:0x006b, B:26:0x0052, B:19:0x003f), top: B:41:0x0008 }] */
    /* JADX WARN: Removed duplicated region for block: B:37:0x0075 A[RETURN] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean equals(java.lang.Object r8) {
        /*
            r7 = this;
            java.lang.String r0 = r7.f3353m
            java.util.ArrayList r1 = r7.f3349b
            r2 = 0
            if (r8 != 0) goto L8
            return r2
        L8:
            com.google.android.gms.auth.api.signin.GoogleSignInOptions r8 = (com.google.android.gms.auth.api.signin.GoogleSignInOptions) r8     // Catch: java.lang.ClassCastException -> L77
            java.lang.String r3 = r8.f3353m     // Catch: java.lang.ClassCastException -> L77
            android.accounts.Account r4 = r8.f3350c     // Catch: java.lang.ClassCastException -> L77
            java.util.ArrayList r5 = r7.f3355o     // Catch: java.lang.ClassCastException -> L77
            int r5 = r5.size()     // Catch: java.lang.ClassCastException -> L77
            if (r5 > 0) goto L77
            java.util.ArrayList r5 = r8.f3355o     // Catch: java.lang.ClassCastException -> L77
            int r5 = r5.size()     // Catch: java.lang.ClassCastException -> L77
            if (r5 <= 0) goto L1f
            goto L77
        L1f:
            int r5 = r1.size()     // Catch: java.lang.ClassCastException -> L77
            java.util.ArrayList r6 = r8.b()     // Catch: java.lang.ClassCastException -> L77
            int r6 = r6.size()     // Catch: java.lang.ClassCastException -> L77
            if (r5 != r6) goto L77
            java.util.ArrayList r5 = r8.b()     // Catch: java.lang.ClassCastException -> L77
            boolean r1 = r1.containsAll(r5)     // Catch: java.lang.ClassCastException -> L77
            if (r1 != 0) goto L38
            goto L77
        L38:
            android.accounts.Account r1 = r7.f3350c     // Catch: java.lang.ClassCastException -> L77
            if (r1 != 0) goto L3f
            if (r4 != 0) goto L77
            goto L45
        L3f:
            boolean r1 = r1.equals(r4)     // Catch: java.lang.ClassCastException -> L77
            if (r1 == 0) goto L77
        L45:
            boolean r1 = android.text.TextUtils.isEmpty(r0)     // Catch: java.lang.ClassCastException -> L77
            if (r1 == 0) goto L52
            boolean r0 = android.text.TextUtils.isEmpty(r3)     // Catch: java.lang.ClassCastException -> L77
            if (r0 == 0) goto L77
            goto L59
        L52:
            boolean r0 = r0.equals(r3)     // Catch: java.lang.ClassCastException -> L77
            if (r0 != 0) goto L59
            goto L77
        L59:
            boolean r0 = r7.f3352f     // Catch: java.lang.ClassCastException -> L77
            boolean r1 = r8.f3352f     // Catch: java.lang.ClassCastException -> L77
            if (r0 != r1) goto L77
            boolean r0 = r7.f3351d     // Catch: java.lang.ClassCastException -> L77
            boolean r1 = r8.f3351d     // Catch: java.lang.ClassCastException -> L77
            if (r0 != r1) goto L77
            boolean r0 = r7.e     // Catch: java.lang.ClassCastException -> L77
            boolean r1 = r8.e     // Catch: java.lang.ClassCastException -> L77
            if (r0 != r1) goto L77
            java.lang.String r0 = r7.f3356p     // Catch: java.lang.ClassCastException -> L77
            java.lang.String r8 = r8.f3356p     // Catch: java.lang.ClassCastException -> L77
            boolean r8 = android.text.TextUtils.equals(r0, r8)     // Catch: java.lang.ClassCastException -> L77
            if (r8 == 0) goto L77
            r8 = 1
            return r8
        L77:
            return r2
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.auth.api.signin.GoogleSignInOptions.equals(java.lang.Object):boolean");
    }

    public final int hashCode() {
        ArrayList arrayList = new ArrayList();
        ArrayList arrayList2 = this.f3349b;
        int size = arrayList2.size();
        for (int i4 = 0; i4 < size; i4++) {
            arrayList.add(((Scope) arrayList2.get(i4)).f3371b);
        }
        Collections.sort(arrayList);
        int iHashCode = arrayList.hashCode() + (31 * 1);
        Account account = this.f3350c;
        int iHashCode2 = (iHashCode * 31) + (account == null ? 0 : account.hashCode());
        String str = this.f3353m;
        int iHashCode3 = (((((((iHashCode2 * 31) + (str == null ? 0 : str.hashCode())) * 31) + (this.f3352f ? 1 : 0)) * 31) + (this.f3351d ? 1 : 0)) * 31) + (this.e ? 1 : 0);
        String str2 = this.f3356p;
        return (31 * iHashCode3) + (str2 != null ? str2.hashCode() : 0);
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3348a);
        AbstractC0184a.l0(parcel, 2, b(), false);
        AbstractC0184a.h0(parcel, 3, this.f3350c, i4, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f3351d ? 1 : 0);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e ? 1 : 0);
        AbstractC0184a.o0(parcel, 6, 4);
        parcel.writeInt(this.f3352f ? 1 : 0);
        AbstractC0184a.i0(parcel, 7, this.f3353m, false);
        AbstractC0184a.i0(parcel, 8, this.f3354n, false);
        AbstractC0184a.l0(parcel, 9, this.f3355o, false);
        AbstractC0184a.i0(parcel, 10, this.f3356p, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
