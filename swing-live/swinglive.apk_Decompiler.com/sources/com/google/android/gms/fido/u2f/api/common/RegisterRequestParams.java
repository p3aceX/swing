package com.google.android.gms.fido.u2f.api.common;

import M0.W;
import N0.c;
import N0.g;
import N0.h;
import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public class RegisterRequestParams extends RequestParams {
    public static final Parcelable.Creator<RegisterRequestParams> CREATOR = new W(24);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Integer f3620a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Double f3621b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Uri f3622c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f3623d;
    public final ArrayList e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final c f3624f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f3625m;

    public RegisterRequestParams(Integer num, Double d5, Uri uri, ArrayList arrayList, ArrayList arrayList2, c cVar, String str) {
        this.f3620a = num;
        this.f3621b = d5;
        this.f3622c = uri;
        F.a("empty list of register requests is provided", (arrayList == null || arrayList.isEmpty()) ? false : true);
        this.f3623d = arrayList;
        this.e = arrayList2;
        this.f3624f = cVar;
        HashSet hashSet = new HashSet();
        if (uri != null) {
            hashSet.add(uri);
        }
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            g gVar = (g) it.next();
            F.a("register request has null appId and no request appId is provided", (uri == null && gVar.f1121d == null) ? false : true);
            String str2 = gVar.f1121d;
            if (str2 != null) {
                hashSet.add(Uri.parse(str2));
            }
        }
        Iterator it2 = arrayList2.iterator();
        while (it2.hasNext()) {
            h hVar = (h) it2.next();
            F.a("registered key has null appId and no request appId is provided", (uri == null && hVar.f1123b == null) ? false : true);
            String str3 = hVar.f1123b;
            if (str3 != null) {
                hashSet.add(Uri.parse(str3));
            }
        }
        F.a("Display Hint cannot be longer than 80 characters", str == null || str.length() <= 80);
        this.f3625m = str;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof RegisterRequestParams)) {
            return false;
        }
        RegisterRequestParams registerRequestParams = (RegisterRequestParams) obj;
        if (!F.j(this.f3620a, registerRequestParams.f3620a) || !F.j(this.f3621b, registerRequestParams.f3621b) || !F.j(this.f3622c, registerRequestParams.f3622c) || !F.j(this.f3623d, registerRequestParams.f3623d)) {
            return false;
        }
        ArrayList arrayList = this.e;
        ArrayList arrayList2 = registerRequestParams.e;
        return ((arrayList == null && arrayList2 == null) || (arrayList != null && arrayList2 != null && arrayList.containsAll(arrayList2) && arrayList2.containsAll(arrayList))) && F.j(this.f3624f, registerRequestParams.f3624f) && F.j(this.f3625m, registerRequestParams.f3625m);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f3620a, this.f3622c, this.f3621b, this.f3623d, this.e, this.f3624f, this.f3625m});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.f0(parcel, 2, this.f3620a);
        AbstractC0184a.d0(parcel, 3, this.f3621b);
        AbstractC0184a.h0(parcel, 4, this.f3622c, i4, false);
        AbstractC0184a.l0(parcel, 5, this.f3623d, false);
        AbstractC0184a.l0(parcel, 6, this.e, false);
        AbstractC0184a.h0(parcel, 7, this.f3624f, i4, false);
        AbstractC0184a.i0(parcel, 8, this.f3625m, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
