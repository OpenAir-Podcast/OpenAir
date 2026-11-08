package com.liquidhive.openair

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class OpenAirWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.openair_widget)
            val title = HomeWidgetPlugin.getData(context, "title", "OpenAir") ?: "OpenAir"
            val author = HomeWidgetPlugin.getData(context, "author", "Not playing") ?: "Not playing"
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_author, author)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}